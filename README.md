# 观盘 · 中文加密货币看盘工作台

本页面仅提供 Docker 镜像、安装说明和更新记录。原源码仓库及其历史已删除，项目源码不再上传到这里。

## 三个镜像，一套软件

| 组件 | 镜像 | 功能 |
| --- | --- | --- |
| 网页 | `ghcr.io/taotaomo/guanpan-web:latest` | 中文图表、绘图工具、指标和代码编辑器 |
| 行情采集 | `ghcr.io/taotaomo/guanpan-collector:latest` | 公开行情、清算归档、后台警报和升级管理 |
| Pine 执行 | `ghcr.io/taotaomo/guanpan-pine-engine:latest` | 指标计算、策略模拟回测 |

[网页镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-web) · [采集镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-collector) · [Pine 镜像](https://github.com/users/taotaomo/packages/container/package/guanpan-pine-engine)

三个组件都必需，区别是功能，不是旧版本。公开镜像无需登录即可下载。

## 安装与更新

部署配置及新版在线升级功能正在完成验证。发布完成后，这里会提供只含镜像引用的 Compose 配置。不要将本地源码、账户密钥、数据库或私人脚本上传到本页。

默认网页地址为 http://127.0.0.1:5188/ ，仅监听本机。已安装用户须保留 `guanpan` 项目名及数据卷，不要使用 `docker compose down -v`。

## 功能范围

中文界面与设置、主流交易所加密货币、17 档周期、常用技术指标、绘图、独立副图、Pine 5/6 实验兼容和后台 Webhook。无需登录，不提供下单功能。清算热力图为标注的估算；Pine 并非 TradingView 官方执行器，不能保证全部脚本完全兼容。

## 许可证

镜像保留第三方许可证。Pine 执行服务采用 AGPL-3.0-only；对应源码获取方式随该组件提供。

## 维护方式

只在本地实际修改并验证后发布新镜像，不创建定时维护任务。