# 观盘 · 中文加密货币看盘工作台

本页面仅提供 Docker 镜像、安装说明和更新记录。原源码仓库及其历史已删除，主项目源码不再上传到这里。

[最新发布](https://github.com/taotaomo/guanpan/releases/latest) · [部署配置](https://github.com/taotaomo/guanpan/blob/main/compose.release.yaml)

## 三个镜像，一套软件

| 组件 | 镜像 | 功能 |
| --- | --- | --- |
| 网页 | `ghcr.io/taotaomo/guanpan-web:latest` | 中文图表、绘图工具、指标和代码编辑器 |
| 行情采集 | `ghcr.io/taotaomo/guanpan-collector:latest` | 公开行情、清算归档、后台警报和升级管理 |
| Pine 执行 | `ghcr.io/taotaomo/guanpan-pine-engine:latest` | 指标计算、策略模拟回测 |

[网页镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-web) · [采集镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-collector) · [Pine 镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-pine-engine)

公开镜像无需登录即可下载，支持 Linux amd64 与 arm64。升级管理服务复用行情采集镜像，因此四个运行容器仅使用三个镜像。

## 安装

先安装 Docker 与 Docker Compose，在一个空目录执行：

```sh
curl -fL https://raw.githubusercontent.com/taotaomo/guanpan/main/compose.release.yaml -o compose.release.yaml
docker compose -p guanpan -f compose.release.yaml pull
docker compose -p guanpan -f compose.release.yaml up -d
```

打开 http://127.0.0.1:5188/ 。默认仅监听本机；数据保存在 Docker 数据卷。Pine 执行服务和升级服务不开放独立主机端口。升级服务使用 Docker socket，仅允许管理 `guanpan` 项目的三个指定组件；不要把页面公开到不可信网络。

## 在线升级

工作台设置 → 常规 → 版本与在线升级，点击 **检查更新**，检测到新版后点击金色 **立即升级**。页面显示下载、替换服务、健康检查等进度，完成后自动刷新。三个组件必须版本一致，升级失败会尝试恢复原容器和采集数据。

升级会短暂中断观盘服务。请保留 `guanpan` 项目名和现有数据卷，**不要执行 `docker compose down -v`**。浏览器工作区保存在原浏览器地址中；更换地址或浏览器不会自动转移。

备用命令：

```sh
docker compose -p guanpan -f compose.release.yaml pull
docker compose -p guanpan -f compose.release.yaml up -d
```

当前发布 **0.2.1**：升级按钮加入图标、边框、禁用状态和进度条；升级后自动刷新，并正确显示“已是最新”。已验证一次完整在线升级。

## 功能范围

中文界面与设置、主流交易所加密货币、17 档周期、常用技术指标、绘图、独立副图、Pine 5/6 实验兼容和后台 Webhook。无需登录，不提供下单功能。清算热力图为标注的估算；Pine 并非 TradingView 官方执行器，不能保证全部脚本完全兼容。

## 发布文件与许可证

本仓库仅保留说明、Compose 配置和镜像同步工作流，没有主项目源码。Release 的自动生成 Source code 压缩包只包含上述发布文件。OCI 文件是镜像传输包，其中省略的公共基础层由发布流程补全，不能直接作为完整离线镜像导入。

镜像保留第三方许可证。Pine 执行服务采用 AGPL-3.0-only；该组件对应源码随镜像提供，运行后可从 `/data/pine/source` 获取，不包含主网页或采集服务源码、账户密钥、数据库或私人脚本。

## 维护方式

只在本地实际修改并验证后发布新镜像，不创建定时维护任务。三个镜像仅保留最新版所需的发布清单及两个平台清单。