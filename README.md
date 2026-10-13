# 观盘 · 中文加密货币看盘工作台

本页面仅提供 Docker 镜像、安装说明和更新记录。原源码仓库及其历史已删除，主项目源码不再上传到这里。

[一键部署](#一键部署) · [最新发布](https://github.com/taotaomo/guanpan/releases/latest) · [部署配置](https://github.com/taotaomo/guanpan/blob/main/compose.release.yaml)

## 三个镜像，一套软件

| 组件 | 镜像 | 功能 |
| --- | --- | --- |
| 网页 | `ghcr.io/taotaomo/guanpan-web:latest` | 中文图表、绘图工具、指标和代码编辑器 |
| 行情采集 | `ghcr.io/taotaomo/guanpan-collector:latest` | 公开行情、清算归档、后台警报和升级管理 |
| Pine 执行 | `ghcr.io/taotaomo/guanpan-pine-engine:latest` | 指标计算、策略模拟回测 |

[网页镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-web) · [采集镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-collector) · [Pine 镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-pine-engine)

公开镜像无需登录即可下载，支持 Linux amd64 与 arm64。升级管理服务复用行情采集镜像，因此四个运行容器仅使用三个镜像。

## 一键部署

**先安装并启动 Docker，随后复制下面整条命令到终端。** 不需要下载项目源码，不需要 GitHub 账号或令牌。

- macOS / Windows：[安装 Docker Desktop](https://docs.docker.com/desktop/)。Windows 需使用 Linux 容器；一键命令可在 WSL 的 Bash 终端执行。
- Linux 服务器：[安装 Docker Engine](https://docs.docker.com/engine/install/) 和 [Docker Compose 插件](https://docs.docker.com/compose/install/linux/)。当前用户需能执行 `docker info`。
- 支持 Linux amd64 / arm64 镜像，需能访问 GitHub 与 GHCR。容器合计配置内存上限约 864 MiB，建议为 Docker 至少预留 1 GiB 可用内存。

### macOS / Linux / Windows WSL

```bash
curl -fL --retry 3 https://raw.githubusercontent.com/taotaomo/guanpan/main/install.sh -o /tmp/guanpan-install.sh && bash /tmp/guanpan-install.sh
```

脚本默认安装到 `~/guanpan`，自动下载配置、拉取三个最新镜像、启动四个服务并等待健康检查。出现 **观盘部署成功** 后，在安装机器打开 **http://127.0.0.1:5188/** 。

[查看一键脚本](https://github.com/taotaomo/guanpan/blob/main/install.sh)。重复运行会使用已有配置并保留数据；不会删除数据卷、清理其他 Docker 项目或覆盖已有 `.env`。安装到指定目录：

```bash
GUANPAN_DIR="$HOME/apps/guanpan" bash /tmp/guanpan-install.sh
```

若已经在其他目录运行观盘，优先使用原网页的在线升级；脚本会提示原部署目录，避免创建重复项目。首次安装不需要填写交易所密钥，公开行情即可使用。

### Windows PowerShell

安装并启动 Docker Desktop 后，打开 PowerShell 执行：

```powershell
New-Item -ItemType Directory -Force "$HOME\guanpan" | Out-Null
Set-Location "$HOME\guanpan"
if (!(Test-Path compose.release.yaml)) { Invoke-WebRequest "https://raw.githubusercontent.com/taotaomo/guanpan/main/compose.release.yaml" -OutFile compose.release.yaml }
docker compose -p guanpan -f compose.release.yaml pull
if ($LASTEXITCODE -ne 0) { throw "镜像下载失败，请检查网络" }
docker compose -p guanpan -f compose.release.yaml up -d --wait --wait-timeout 180
if ($LASTEXITCODE -ne 0) { throw "启动或健康检查失败，请查看容器日志" }
```

打开 **http://127.0.0.1:5188/**。已有其他目录的观盘项目请使用原目录及配置。

### 远程服务器怎么访问

在服务器执行一键部署命令后，在自己的电脑建立 SSH 隧道（将 `用户名@服务器IP` 替换为实际信息）：

```bash
ssh -N -L 5188:127.0.0.1:5188 用户名@服务器IP
```

保持此终端运行，在自己电脑的浏览器打开 **http://127.0.0.1:5188/**。如本机 5188 端口已被占用，可改成 `ssh -N -L 5189:127.0.0.1:5188 用户名@服务器IP`，再打开 `http://127.0.0.1:5189/`。

默认网页仅监听本机，服务器无需开放 5188 公网端口。软件没有登录功能，不建议直接对公网开放。Pine 和升级服务不开放独立主机端口；升级服务挂载 Docker socket，仅管理观盘指定组件。

### 手动部署

在空目录执行：

```bash
curl -fL https://raw.githubusercontent.com/taotaomo/guanpan/main/compose.release.yaml -o compose.release.yaml
docker compose -p guanpan -f compose.release.yaml pull
docker compose -p guanpan -f compose.release.yaml up -d --wait --wait-timeout 180
```

请保留项目名 `guanpan`。默认部署不需要 `.env`；需要只读账户同步时，在服务端自行配置，切勿将密钥上传 GitHub。

### 查看日志、停止和恢复

在部署目录执行：

```bash
# 查看服务状态
docker compose -p guanpan -f compose.release.yaml ps
# 查看最近日志
docker compose -p guanpan -f compose.release.yaml logs --tail 100
# 停止服务，保留数据
docker compose -p guanpan -f compose.release.yaml stop
# 恢复服务
docker compose -p guanpan -f compose.release.yaml up -d --wait --wait-timeout 180
```

**不要使用 `docker compose down -v`**，它会删除数据卷。浏览器工作区保存在浏览器，采集数据和后台任务保存在 Docker 数据卷；备份时两者都需要保留。

### 常见部署问题

| 提示或现象 | 处理方法 |
| --- | --- |
| 找不到 Docker / 无法连接 Docker | 安装并启动 Docker Desktop，或启动 Linux Docker 服务；确认当前终端能执行 `docker info` |
| 不认识 `--wait` | 更新 Docker Compose 插件后重试 |
| 无法拉取 GHCR 镜像 | 检查机器访问 GitHub / GHCR 的网络及 Docker 代理；镜像公开，无需登录 |
| 5188 端口被占用 | 检查是否已有观盘实例，使用原实例或先处理端口冲突 |
| 健康检查失败 | 查看上面的日志命令；修复后重新启动，脚本不会删除已有数据 |
| 服务器部署成功但电脑打不开 | 按远程服务器说明建立 SSH 隧道；本地访问地址指向自己的电脑 |


## 在线升级

工作台设置 → 常规 → 版本与在线升级，点击 **检查更新**，检测到新版后点击金色 **立即升级**。页面显示下载、替换服务、健康检查等进度，完成后自动刷新。三个组件必须版本一致，升级失败会尝试恢复原容器和采集数据。

升级会短暂中断观盘服务。请保留 `guanpan` 项目名和现有数据卷，**不要执行 `docker compose down -v`**。浏览器工作区保存在原浏览器地址中；更换地址或浏览器不会自动转移。

备用命令：

```sh
docker compose -p guanpan -f compose.release.yaml pull
docker compose -p guanpan -f compose.release.yaml up -d
```

当前发布 **0.3.2**：右侧固定交易栏与底部可折叠账户区已完成独立审计。修复历史分页重复、旧合约预览与跨账户回执串入、面板高度与拖动范围不一致；补齐分类键盘操作、同步状态和撤单核对。工作区使用版本比较与三方合并，多页面笔记及绘图不会静默覆盖；冲突可以明确选择数据库或浏览器版本。

## Lighter 下单与本地数据库

[完整配置和使用说明](https://github.com/taotaomo/guanpan/blob/main/LIGHTER.md)

右侧竖栏 **交易** 打开 Lighter 固定下单面板，图表与表单同时可见。底部 **交易账户** 按钮展开或收起账户区，可拖动上边界调整高度。选择交易合约会联动 Lighter 图表，预览和确认按钮固定在右侧底部。支持 USDC 永续的限价、市价、仅挂单、仅减仓、委托预览、持仓查询和本工作台委托撤单。服务端使用官方 SDK 1.1.6，私钥不发送到浏览器。没有账户配置时可以查看行情及预览委托，真实提交按钮禁用。

在部署目录的 `.env` 配置 `LIGHTER_ACCOUNT_INDEX`、`LIGHTER_API_KEY_INDEX`、`LIGHTER_API_KEY_PRIVATE_KEY`，并显式设置 `LIGHTER_TRADING_ENABLED=true`。仅使用 Lighter API 私钥，不填写钱包私钥或助记词；为本工作台使用独立 API 密钥索引。修改后运行：

```bash
docker compose -p guanpan -f compose.release.yaml up -d --no-deps --force-recreate collector
```

**工作台设置 → 常规 → 本地数据库** 可以查看 SQLite 状态、切换工作区自动保存、载入数据库工作区，以及一致性备份下载。数据库位于 `/data/workspace.sqlite`，持久保存在 `guanpan_liquidation-data` 数据卷中。任务、工作区、订单和持仓快照都在本机；数据库和账户密钥不会随镜像上传 GitHub。

268 项回归测试通过；公开 Lighter 行情已实际验证，账户表格与平仓预填使用隔离样例验证。没有使用真实账户下单，配置账户后首次订单由使用者手动核对并确认。

## 功能范围

中文界面与设置、主流交易所加密货币、17 档周期、常用技术指标、绘图、独立副图、Pine 5/6 实验兼容和后台 Webhook。无需登录，支持 Lighter 手动下单；交易默认关闭，配置服务端账户后由用户手动确认。清算热力图为标注的估算；Pine 并非 TradingView 官方执行器，不能保证全部脚本完全兼容。

## 发布文件与许可证

本仓库仅保留说明、一键部署脚本、Compose 配置和镜像同步工作流，没有主项目源码。Release 的自动生成 Source code 压缩包只包含上述发布文件。OCI 文件是镜像传输包，其中省略的公共基础层由发布流程补全，不能直接作为完整离线镜像导入。

镜像保留第三方许可证。Pine 执行服务采用 AGPL-3.0-only；该组件对应源码随镜像提供，运行后可从 `/data/pine/source` 获取，不包含主网页或采集服务源码、账户密钥、数据库或私人脚本。

## 维护方式

只在本地实际修改并验证后发布新镜像，不创建定时维护任务。三个镜像仅保留最新版所需的发布清单及两个平台清单。