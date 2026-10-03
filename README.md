<h1 align="center">
  <img src="./src-tauri/icons/icon.png" alt="Clash" width="128" />
  <br>
  Continuation of <a href="https://github.com/zzzgydi/clash-verge">Clash Verge</a>
  <br>
</h1>

<h3 align="center">
A Clash Meta GUI based on <a href="https://github.com/tauri-apps/tauri">Tauri</a>.
</h3>

<p align="center">
  Languages:
  <a href="./README.md">简体中文</a> ·
  <a href="./docs/README_en.md">English</a>
</p>

> ### 🌟 特别定制：Compat Edition（双内核兼容版）
>
> **这是什么**：官方 Clash Verge Rev 的定制分支，用于解决 **从 v2.5.1 升级至 v2.5.2+ 后，部分机场订阅因新内核兼容性变更导致节点丢失 / Unknown / 超时** 的问题。客户端保持官方最新特性，同时额外内置 **v2.5.1 稳定兼容内核（Mihomo v1.19.25）**。
>
> | 特性 | 说明 |
> | :--- | :--- |
> | **三内核自由切换** | `设置` → `Clash 内核` ⚙：正式版 / Alpha 预览版 / **兼容版 (v2.5.1)** |
> | **订阅零改动** | 切换即自动重启内核，订阅、配置、规则完整保留 |
> | **服务模式 & TUN** | 兼容内核同样注册进系统服务，TUN 虚拟网卡可用 |
> | **升级保护** | 在线「升级内核」不会误覆盖兼容内核（固定 v1.19.25） |
> | **自动更新已禁用** | 防止自动更新装回官方版丢失兼容内核，更新请回本仓库获取 |
>
> **📥 下载**：[本仓库 Releases](https://github.com/dai123x/clash-verge-rev/releases)（当前发布 `v2.5.8-compat.4`，Windows x64 安装包，支持从官方版直接覆盖安装）
>
> **📖 完整说明**（使用教程 / 内核选择 / 与官方版差异 / 技术实现 / 自行构建 / FAQ）：**[docs/COMPAT_EDITION.md](./docs/COMPAT_EDITION.md)**　|　**[📜 更新日志](./docs/CHANGELOG_COMPAT.md)**


## Preview

| Dark                             | Light                             |
| -------------------------------- | --------------------------------- |
| ![预览](./docs/preview_dark.png) | ![预览](./docs/preview_light.png) |

## Install

请到发布页面下载对应的安装包：[Release page](https://github.com/clash-verge-rev/clash-verge-rev/releases)<br>
Go to the [Release page](https://github.com/clash-verge-rev/clash-verge-rev/releases) to download the corresponding installation package<br>
Supports Windows (x64/x86), Linux (x64/arm64) and macOS 11+ (intel/apple).

#### 我应当怎样选择发行版

| 版本        | 特征                                     | 链接                                                                                   |
| :---------- | :--------------------------------------- | :------------------------------------------------------------------------------------- |
| Stable      | 正式版，高可靠性，适合日常使用。         | [Release](https://github.com/clash-verge-rev/clash-verge-rev/releases)                 |
| Alpha(废弃) | 测试发布流程。                           | [Alpha](https://github.com/clash-verge-rev/clash-verge-rev/releases/tag/alpha)         |
| AutoBuild   | 滚动更新版，适合测试反馈，可能存在缺陷。 | [AutoBuild](https://github.com/clash-verge-rev/clash-verge-rev/releases/tag/autobuild) |

#### 安装说明和常见问题，请到 [文档页](https://clash-verge-rev.github.io/) 查看

## Features

- 基于性能强劲的 Rust 和 Tauri 2 框架
- 内置[Clash.Meta(mihomo)](https://github.com/MetaCubeX/mihomo)内核，并支持切换 `Alpha` 版本内核。
- 简洁美观的用户界面，支持自定义主题颜色、代理组/托盘图标以及 `CSS Injection`。
- 配置文件管理和增强（Merge 和 Script），配置文件语法提示。
- 系统代理和守卫、`TUN(虚拟网卡)` 模式。
- 可视化节点和规则编辑
- WebDav 配置备份和同步

### FAQ

Refer to [Doc FAQ Page](https://clash-verge-rev.github.io/faq/windows.html)

## Development

See [CONTRIBUTING.md](./CONTRIBUTING.md) for more details.

To run the development server, execute the following commands after all prerequisites for **Tauri** are installed:

```shell
pnpm i
pnpm run prebuild
pnpm dev
```

`pnpm dev` preserves the Development Channel's installed service state: an
existing service is used, while a previously uninstalled service remains
uninstalled and the app starts in Sidecar mode. Use `pnpm dev:service` to
explicitly install or update the isolated development service before launch,
or `pnpm dev:sidecar` to force the unprivileged Sidecar workflow.

## Contributions

Issue and PR welcome!

## Acknowledgement

Clash Verge rev was based on or inspired by these projects and so on:

- [zzzgydi/clash-verge](https://github.com/zzzgydi/clash-verge): A Clash GUI based on tauri. Supports Windows, macOS and Linux.
- [tauri-apps/tauri](https://github.com/tauri-apps/tauri): Build smaller, faster, and more secure desktop applications with a web frontend.
- [Dreamacro/clash](https://github.com/Dreamacro/clash): A rule-based tunnel in Go.
- [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo): A rule-based tunnel in Go.
- [Fndroid/clash_for_windows_pkg](https://github.com/Fndroid/clash_for_windows_pkg): A Windows/macOS GUI based on Clash.
- [vitejs/vite](https://github.com/vitejs/vite): Next generation frontend tooling. It's fast!

## Privacy

Clash Verge Rev 不收集任何用户数据，配置与日志仅保存在本地。详见[隐私政策](./PRIVACY.md)。

Clash Verge Rev does not collect any user data; configuration and logs stay on
your own device. See the [Privacy Policy](./PRIVACY.md) for details.

## License

GPL-3.0 License. See [License here](./LICENSE) for details.
