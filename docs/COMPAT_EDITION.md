# Clash Verge Rev · Compat Edition（双内核兼容版）完整说明

> 本文档面向使用本分支构建版本的用户，以及想了解其原理、自行审计或构建的开发者。

---

## 目录

- [一、这是什么](#一这是什么)
- [二、解决的问题](#二解决的问题)
- [三、下载与安装](#三下载与安装)
- [四、使用教程：切换兼容内核](#四使用教程切换兼容内核)
- [五、三种内核如何选择](#五三种内核如何选择)
- [六、与官方版的完整差异](#六与官方版的完整差异)
- [七、技术实现细节](#七技术实现细节)
- [八、自行构建指南](#八自行构建指南)
- [九、常见问题 FAQ](#九常见问题-faq)
- [十、安全与审计说明](#十安全与审计说明)
- [十一、致谢与许可](#十一致谢与许可)

---

## 一、这是什么

**Compat Edition（双内核兼容版）** 是基于官方 [clash-verge-rev/clash-verge-rev](https://github.com/clash-verge-rev/clash-verge-rev)（dev 分支，v2.5.8 代码基线）的特别定制分支。

它在**完整保留官方最新客户端全部功能**的前提下，额外内置了第三个 Clash 内核——**v2.5.1 稳定兼容内核（Mihomo v1.19.25）**，让你在遇到新版内核的订阅兼容性问题时，无需降级整个客户端、无需改动任何订阅配置，**一键切换**即可恢复正常。

> 💡 界面中显示的 "v2.5.1" 指的是**官方客户端 v2.5.1 所搭载的内核世代**；该选项实际使用的内核为 **Mihomo v1.19.25**（对应关系已核实：官方 v2.5.1 发布于 2026-05-20，mihomo v1.19.25 发布于 2026-05-16，官方客户端构建时拉取当时最新稳定内核）。

---

## 二、解决的问题

部分用户从官方 **v2.5.1 升级到 v2.5.2+** 之后，反馈以下现象：

- 之前正常的机场订阅，升级后节点**全部显示 Unknown**；
- 订阅**节点数量减少或为空**；
- 节点**延迟测试超时**、代理不可用；
- 日志中出现订阅解析相关的报错。

其原因是新版 Mihomo 内核对部分机场订阅的写法（如 Inline Provider 等）与新内核 API 的兼容性发生了变化，并非订阅本身失效。

**Compat Edition 的思路**：客户端保持最新版（界面、规则、功能均不缩水），只把"内核引擎"一键回退到与 v2.5.1 相同的稳定版本。老的订阅遇到老的内核，一切照旧。

---

## 三、下载与安装

### 下载

前往本仓库的 [**Releases 发布页**](https://github.com/dai123x/clash-verge-rev/releases) 下载安装包：

| 发布版本 | 安装包 | 说明 |
| :--- | :--- | :--- |
| `v2.5.8-compat.1` | `Clash.Verge_2.5.8_x64-setup.exe`（约 68.6 MB） | Windows 10/11 x64 |
| `v2.5.8-compat.1` | `Clash.Verge_2.5.8_x64-setup.zip`（约 68.6 MB） | 同一安装包的 zip 打包；浏览器出现下载拦截提示时可选此格式，解压后得到相同的 exe |

### 安装

- **从官方版 / 旧版覆盖安装**：直接运行安装包即可（同一产品标识，安装器会自动停止正在运行的内核与客户端进程）。如遇异常，可先卸载官方版再安装，配置目录不受影响。
- **全新安装**：直接运行安装包，按提示完成即可。
- 安装包内置全部三个内核（正式版 / Alpha / 兼容版），并自动完成系统服务注册。

> 当前 CI 流水线只额外产出 **Windows x64** 安装包；macOS / Linux 用户如需兼容内核，可参照[第八节](#八自行构建指南)自行构建。

---

## 四、使用教程：切换兼容内核

1. 打开 Clash Verge 客户端；
2. 进入左侧 **「设置」** 页面；
3. 找到 **「Clash 内核」** 一栏，点击右侧的 **⚙ 齿轮图标**；
4. 在弹出的内核列表中选择 **「兼容版 (v2.5.1)」**；
5. 客户端会**自动切换并重启内核**，无需其他操作。

切换完成后，重新进入「代理」页刷新节点，之前 Unknown / 丢失 / 超时的订阅节点应立即恢复正常。

> 切换内核**不会影响**你的订阅链接、配置文件、规则和界面偏好，可随时切回其它内核。

---

## 五、三种内核如何选择

| 内核选项 | 内核来源 | 适合场景 |
| :--- | :--- | :--- |
| **正式版** | Mihomo 最新稳定版（官方渠道，可在线升级） | 日常使用首选；订阅无兼容问题时用它 |
| **预览版（Alpha）** | Mihomo 每日构建 | 想第一时间体验新特性 |
| **兼容版 (v2.5.1)** | Mihomo v1.19.25（固定版本，不参与在线升级） | 订阅在新内核下出现 Unknown / 丢失 / 超时 / 报错 |

- 兼容版内核是**固定版本**，设置里的「升级内核」对它无效（有专门防护，防止误覆盖）；
- 想用回最新内核时，在同一列表切回「正式版」即可。

---

## 六、与官方版的完整差异

| 差异点 | 官方版 | Compat Edition |
| :--- | :--- | :--- |
| Clash 内核数量 | 2 个（正式版 / Alpha） | **3 个**（新增兼容版） |
| 服务模式（Service Mode） | 支持 | 支持，且**兼容内核同样注册进服务**，TUN 模式可用 |
| 「升级内核」功能 | 正式版 / Alpha 可在线升级 | 兼容版被防护拦截，不会误升级；其余不变 |
| 客户端自动更新 | 可用 | **已禁用**（原因见下），请回本仓库 Releases 手动获取新版 |
| 界面语言 | 多语言 | 内核切换相关提示补充了 简中 / 繁中 / 英文 |
| 其余全部功能 | — | 与官方完全一致 |

**为什么禁用自动更新？**
1. 本分支没有官方版的更新签名私钥，无法产出合法的更新签名文件；
2. 内置更新器的更新源指向官方仓库，若保留，客户端点「检查更新」会**直接装回官方版，兼容内核随之丢失**。

因此 compat 版闭源更新源、关闭更新检查，版本更新请**回到本仓库 Releases 手动下载**。

---

## 七、技术实现细节

### 1. 兼容内核的来源与校验

- 来源：[MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) 官方 Release `v1.19.25`，不做任何修改；
- 构建时由 `scripts/prebuild.mjs` 按目标平台自动下载（Windows zip / 其余平台 tar.gz），并计算 **SHA256** 写入 `src-tauri/packages/windows/core-hashes.nsh`；
- Windows 安装器（NSIS）把三个内核连同哈希一起**注册进系统服务**（`clash-verge-service-install --install-core --sha256`），确保服务模式 / TUN 模式下兼容内核同样可用。

### 2. 主要代码改动清单

| 模块 | 文件 | 作用 |
| :--- | :--- | :--- |
| 前端 UI | `src/components/setting/mods/clash-core-viewer.tsx` | 内核列表新增 "Mihomo Compat (v2.5.1)" 选项与使用提示，弹窗高度自适应 |
| 通知处理 | `src/components/layout/notice-manager.tsx` | 服务端 "second core" 提示的正则兼容 `-compat` 内核名 |
| 多语言 | `src/locales/{zh,en,zhtw}/settings.json` + `src/types/generated/*` | 「兼容版 (v2.5.1)」标签与切换提示的三语文案 |
| 合法内核列表 | `src-tauri/src/config/verge.rs` | `VALID_CLASH_CORES` 注册 `verge-mihomo-compat`，配置校验不误纠 |
| 增强链 | `src-tauri/src/enhance/chain.rs` | 兼容内核按"稳定版 Meta 内核"参与配置预处理与脚本增强 |
| 升级防护 | `src-tauri/src/feat/core_upgrade.rs` | 对兼容内核调用「升级内核」时给出明确拒绝 |
| Tauri 配置 | `src-tauri/tauri.conf.json`、`tauri.linux.conf.json` | `externalBin` 注册 `verge-mihomo-compat` sidecar |
| Windows 安装器 | `src-tauri/packages/windows/installer.nsi` | 打包兼容内核、进程互斥检测、服务注册、卸载清理 `.old` |
| 构建预下载 | `scripts/prebuild.mjs` | 下载 mihomo v1.19.25 并计算三内核 SHA256 |
| 开发服务 | `scripts/dev-service.mjs` | 开发模式服务安装同样带上兼容内核 |
| 构建覆盖 | `src-tauri/tauri.compat.conf.json` | 仅 compat 构建：关闭更新签名产物 + 清空更新源 + 接入 Windows 代码签名命令（见第九节 Q9） |
| CI 流水线 | `.github/workflows/build-compat.yml` | 一键云端打包（Windows x64），tag `v*-compat*` 或手动触发 |
| CI 触发隔离 | `.github/workflows/release.yml` | 官方全平台构建排除 compat 标签，避免无意义的连带失败 |

### 3. 内核切换的工作方式

客户端切换内核时只改变 `verge.yaml` 中的 `clash_core` 字段并重启内核进程；订阅、配置、规则完全不动。兼容内核与正式内核共享同一套配置预处理（Enhance）管线，因此脚本、Merge 等增强功能在两个内核下行为一致。

---

## 八、自行构建指南

### 本地构建（Windows x64 示例）

```bash
git clone https://github.com/dai123x/clash-verge-rev.git
cd clash-verge-rev
pnpm install
pnpm prebuild x86_64-pc-windows-msvc   # 下载三个内核与资源，含 SHA256 校验
pnpm build:compat                      # 产出 NSIS 安装包
```

> 前置要求：Node.js 20+、pnpm、Rust stable（含 `x86_64-pc-windows-msvc` target）。
>
> 自建必须使用 `pnpm build:compat`（即叠加 `src-tauri/tauri.compat.conf.json`），与 CI 构建方式一致：它会关闭 updater 产物并清空官方更新源。直接运行 `pnpm build` 得到的是带官方更新通道的普通版，且本地缺少 `TAURI_SIGNING_PRIVATE_KEY` 时会因 `createUpdaterArtifacts` 直接报错。

### macOS / Linux 构建

```bash
git clone https://github.com/dai123x/clash-verge-rev.git
cd clash-verge-rev
pnpm install
# 按目标平台任选其一执行 prebuild：
pnpm prebuild x86_64-apple-darwin       # macOS (Intel)
pnpm prebuild aarch64-apple-darwin      # macOS (Apple Silicon)
pnpm prebuild x86_64-unknown-linux-gnu  # Linux x86_64
pnpm build:compat
```

> **服务二进制来源说明**：客户端 prebuild 的服务包从本组织的 [clash-verge-service-ipc](https://github.com/dai123x/clash-verge-service-ipc/releases) fork 下载（该服务已打上放行 `verge-mihomo-compat` 内核的补丁）。**v2.7.6 仅发布过 Windows x64 资产**，在此版本上做 macOS / Linux 自建会在服务下载一步失败；服务 fork 的发布矩阵已扩展，**v2.7.7 及之后的 tag 将自动补齐 macOS（x86_64 / aarch64）与 Linux x86_64 资产**，届时三平台自建均可开箱即用。过渡期如需在其他平台自建：把 `src-tauri/Cargo.toml` 中 `clash_verge_service_ipc` 依赖临时改为指向 [服务 fork 本地克隆](https://github.com/dai123x/clash-verge-service-ipc) 的 `path` 依赖，prebuild 会检测到 `path` 依赖并自动从源码构建打过补丁的服务。

### 使用 GitHub Actions 云端构建

1. 打开仓库的 [Actions 页面](https://github.com/dai123x/clash-verge-rev/actions/workflows/build-compat.yml)；
2. 选择左侧 **Build Compat Release**，点击 **Run workflow**；
3. 可自定义 Release 标签名（默认 `v2.5.8-compat.1`），确认后自动构建并发布；
4. 推送任意匹配 `v*-compat*` 的标签也会自动触发。

### Windows 代码签名（仓库维护者）

安装包通过 **Azure Trusted Signing** 签名。CI 中的签名命令（`scripts/sign-file.ps1`）检测到以下仓库 Secrets 才执行签名，否则自动跳过、产物与未签名时完全一致：

| Secret | 说明 |
| :--- | :--- |
| `AZURE_SIGNING_ENDPOINT` | Trusted Signing 账户 Endpoint，如 `https://eus.codesigning.azure.net/` |
| `AZURE_SIGNING_ACCOUNT_NAME` | Trusted Signing 账户名 |
| `AZURE_SIGNING_CERT_PROFILE_NAME` | Public Trust 证书配置文件名 |
| `AZURE_TENANT_ID` / `AZURE_CLIENT_ID` / `AZURE_CLIENT_SECRET` | 拥有 Trusted Signing「Certificate Profile Signer」角色的 Entra 应用注册凭据 |

开启流程：Azure 订阅中创建 Trusted Signing 账户与 **Public Trust** 证书 Profile（Basic 档按月订阅），完成身份校验后创建 Entra 应用注册并授予上述角色，再把上表 Secrets 添加到仓库即可。此后每个 compat 标签构建出的主程序、内核与安装包都会自动带数字签名，浏览器与 SmartScreen 的「未知发布者」提示随之消失。

---

## 九、常见问题 FAQ

**Q1：切换到兼容内核后，需要重新导入订阅吗？**
不需要。切换只替换内核程序，订阅与配置原样保留。

**Q2：兼容内核会让我的其它订阅变慢或变差吗？**
不会。Mihomo v1.19.25 是官方 v2.5.1 时期的稳定内核，功能完备；只是缺少新版内核的部分新特性。建议订阅无问题时切回「正式版」。

**Q3：为什么设置里点「升级内核」对兼容版无效？**
这是刻意的防护：兼容版固定为 v1.19.25，在线升级会把它替换成新内核、破坏兼容性。程序会明确提示而不执行。

**Q4：TUN 模式 / 服务模式能用兼容内核吗？**
能。安装器已把兼容内核连同哈希注册进系统服务，TUN 虚拟网卡正常可用。

**Q5：客户端为什么不提示更新 / 提示更新失败？**
Compat Edition 已禁用自动更新（避免自动装回官方版丢失兼容内核）。新版本请到本仓库 [Releases](https://github.com/dai123x/clash-verge-rev/releases) 手动下载覆盖安装。

**Q6：已装官方版，能直接装这个吗？**
可以直接覆盖安装（同一产品标识）。如遇异常，先卸载官方版再安装即可，配置目录不受影响。

**Q7：卸载时会残留兼容内核吗？**
不会。卸载器会清理全部三个内核及服务注册。

**Q8：支持 macOS / Linux 吗？**
客户端本身跨平台，但当前 CI 只额外产出 Windows x64 安装包；其他平台请参照[第八节](#八自行构建指南)自行构建。

**Q9：下载时浏览器提示「通常不会下载 …_setup.exe」，或运行时 SmartScreen 提示「Windows 已保护你的电脑」怎么办？**

这是 Windows / Edge / Chrome 对**未经代码签名**且下载信誉尚未积累的新文件的**标准信誉提示，不是病毒报告**。本仓库 CI 已接入 **Azure Trusted Signing 代码签名**：签名生效后的新版安装包自带数字签名（右键安装包 → 属性 → 数字签名 可查看），正常情况下不会再出现上述提示。若下载的是凭据配置之前的**历史未签名版本**，处理方式任选其一：

- **浏览器提示**：在下载记录的 `···` 菜单中选 **「保留」**；若出现二次确认，选 **「仍然保留」**；
- **不想看到提示**：直接下载 **`.zip` 版本**（浏览器不拦截 zip），解压后得到完全相同的安装包；
- **安装时 SmartScreen 蓝色提示**：点击 **「更多信息」→「仍要运行」**；
- 安装包直接发布于 GitHub Releases 官方存储，未经过任何第三方改动；对来源有更高要求的用户可参照[第八节](#八自行构建指南)自行构建。

---

## 十、安全与审计说明

- 兼容内核直接取自 [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) 官方 Release，**不做任何修改**，构建时强制 SHA256 校验；
- 全部构建在 **GitHub Actions 公开运行**，日志可见，产物可复现；
- 所有改动均已开源在本仓库 `dev` 分支，可自行审计；
- 如有顾虑，强烈建议参照[第八节](#八自行构建指南)从源码自行构建。

---

## 十一、致谢与许可

- 上游项目：[clash-verge-rev/clash-verge-rev](https://github.com/clash-verge-rev/clash-verge-rev)（GPL-3.0）
- 内核项目：[MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo)
- 本分支遵循上游的 **GPL-3.0** 许可证，改动同样开源。

> 问题反馈：请在本仓库提交 [Issue](https://github.com/dai123x/clash-verge-rev/issues)。
