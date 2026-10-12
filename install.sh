#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C
fail() { printf '\n错误：%s\n' "$*" >&2; exit 1; }
trap 'printf "\n部署未完成，请查看上面的错误。已存在的数据卷不会被删除。\n" >&2' ERR
if ! command -v docker >/dev/null 2>&1 && [ -x /Applications/Docker.app/Contents/Resources/bin/docker ]; then
  export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
fi
command -v docker >/dev/null 2>&1 || fail '请先安装 Docker；macOS / Windows 使用 Docker Desktop，Linux 使用 Docker Engine 和 Compose 插件。'
command -v curl >/dev/null 2>&1 || fail '请先安装 curl。'
docker info >/dev/null 2>&1 || fail 'Docker 未运行或当前用户无权使用 Docker，请先启动 Docker 并确认权限。'
docker compose version >/dev/null 2>&1 || fail '缺少 Docker Compose 插件，请先安装。'
[ "$(docker info --format '{{.OSType}}')" = linux ] || fail '请将 Docker 切换到 Linux 容器模式。'
case "$(docker info --format '{{.Architecture}}')" in
  x86_64|amd64|aarch64|arm64) ;;
  *) fail '当前仅支持 amd64 和 arm64。' ;;
esac
install_dir=${GUANPAN_DIR:-"$HOME/guanpan"}
mkdir -p "$install_dir"
cd "$install_dir"
install_dir=$(pwd -P)
# Avoid taking over an existing project from another directory.
existing_ids=$(docker ps -aq --filter label=com.docker.compose.project=guanpan)
for container_id in $existing_ids; do
  existing_dir=$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' "$container_id")
  [ "$existing_dir" = "$install_dir" ] || fail "已有观盘项目位于 $existing_dir。请在原网页在线升级，或用 GUANPAN_DIR 指向原部署目录；本脚本不会接管其他目录的项目。"
done
compose_file="$install_dir/compose.release.yaml"
if [ ! -e "$compose_file" ]; then
  temp_file=$(mktemp "$install_dir/.compose.download.XXXXXX")
  trap 'rm -f "${temp_file:-}"' EXIT
  printf '正在下载观盘部署配置…\n'
  curl --proto '=https' --tlsv1.2 -fL --retry 3 --connect-timeout 15 --max-time 120 \
    https://raw.githubusercontent.com/taotaomo/guanpan/main/compose.release.yaml -o "$temp_file"
  docker compose -p guanpan -f "$temp_file" config --quiet
  mv "$temp_file" "$compose_file"
  trap - EXIT
else
  printf '使用已有部署配置，保留自定义配置和 .env。\n'
fi
compose=(docker compose -p guanpan -f "$compose_file")
"${compose[@]}" config --quiet
printf '\n正在拉取最新版镜像，无需 GitHub 登录…\n'
"${compose[@]}" pull
printf '\n正在启动观盘并等待服务健康检查…\n'
"${compose[@]}" up -d --wait --wait-timeout 180
"${compose[@]}" ps
printf '\n观盘部署成功！\n网页地址：http://127.0.0.1:5188/\n部署目录：%s\n' "$install_dir"
printf '远程服务器请使用 SSH 隧道访问，详见发布页的服务器部署说明。\n后续升级：工作台设置 → 常规 → 检查更新 → 立即升级。\n'
