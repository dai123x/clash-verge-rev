# Clash Verge Rev · Compat Edition 更新日志

> 本分支（`dai123x/clash-verge-rev` 的 `dev`）基于官方 clash-verge-rev 上游开发，目标是解决官方 v2.5.2+ 内核导致部分机场订阅节点 Unknown / 解析失败的问题：内置第三个内核 **verge-mihomo-compat**（mihomo v1.19.25，即官方 v2.5.1 时代内核），并配套修复系统服务、DNS、流媒体解锁测试等链路。
>
> 发布标签 `v*-compat*` 由 `.github/workflows/build-compat.yml` 构建（仅 Windows x64），官方 `release.yml` 已排除该标签模式。完整使用文档见 [COMPAT_EDITION.md](COMPAT_EDITION.md)；官方通用变更见仓库根 [CHANGELOG.md](../CHANGELOG.md)。

---

## 配套服务端补丁（dai123x/clash-verge-service-ipc，v2.7.6）

系统服务二进制（`clash-verge-service*.exe`）不是本仓库构建的，而是按客户端 `Cargo.toml` 中 `clash_verge_service_ipc` 的版本从上游 releases 下载。fork 版在**协议版本不变（保持 v2.7.6，客户端严格校验）**的前提下打了三类补丁并重新发布：

1. **内核名白名单放行 `verge-mihomo-compat`**：上游服务在 5 处硬编码只认 `verge-mihomo` / `verge-mihomo-alpha`，导致服务模式切换兼容内核时报 `unsupported core name verge-mihomo-compat.exe`（涉及 core 暂存校验、已装内核检查、安装器自动暂存列表、运行中进程检查）。
2. **安装校验上限 2 → 8**：上游硬编码 "at most two cores can be inspected"，而客户端安装服务时一次性提交 3 个内核，校验必然失败。
3. **进程检查覆盖 Linux comm 截断**：Linux 进程名上限 15 字符（`TASK_COMM_LEN = 16` 含 NUL），兼容内核在进程列表中显示为 `verge-mihomo-co`，已将其与 `verge-mihomo-al` 一并纳入残留进程检查（带单元测试）。
4. **构建矩阵**：覆盖全部客户端平台（Windows x86_64、macOS arm64/x86_64、Linux x86_64），未配置签名证书时 macOS 产物 ad-hoc 签名兜底；客户端 Windows 预构建只消费其中的 `x86_64-pc-windows-msvc` 产物。

客户端 `scripts/service-release.mjs` 的下载地址同步指向 fork 仓库。

---

## v2.5.8-compat.6（2026-10-06，提交 d66bb23）

- **chore(sync)**：合并官方 `dev`（10 个提交），含多项 Windows 实际修复——单实例锁文件权限原地修复（`4a0882fc`）、不再等待无法随 Windows 启动的服务（`57c54840`）、代理组内 provider 成员按组解析（`a9a3cfa3`）、混合端口编辑改用保存值而非会话回退（`7cc6c1ed`），以及 npm/cargo 依赖与 Rust 1.99 工具链更新。
- **fix(tray)**：收编托盘菜单事件通道修复——解决托盘菜单使用一段时间后所有菜单项（含「退出」）点击无响应的问题（上游 issue #8159）。菜单内容签名未变时跳过重建、菜单对象改在主线程构建、弹出期间延迟破坏性替换（`cf30d416`），并对原生菜单替换增加兜底保护（`1f71295c`）。对应上游 PR #8164 已被关闭，本 fork 将其作为自有补丁长期维护。
- **fix(ci)**：`build-compat.yml` 的 `GITHUB_TOKEN` 权限从 `write-all` 收紧到 `contents: write`；发布产物附带 `SHA256SUMS.txt`（exe + zip，sha256sum 兼容格式），下载后可自行校验完整性。
- **fix(i18n)**：「升级内核」拒绝兼容内核的报错从中文改为英文（与同文件其他报错风格一致）；内核选择器底部提示改为明确标注对应关系——列表中的「(v2.5.1)」指 Clash Verge 版本，兼容内核实际是其中的 Mihomo v1.19.25。

## v2.5.8-compat.5（2026-10-04，提交见 dev）

- **fix(home)**：精简「IP 信息」检测服务列表——移除 `api.ipapi.is`（接口长期失效）与 `api.ip.sb`（国内出口下常超时）。二者留在随机轮询列表里只会消耗 5 秒超时预算，最坏情况让卡片多等 5-10 秒；保留 `ipapi.co` / `ipwho.is` / `ip.api.skk.moe` / `get.geojs.io` 四个实测健康的服务，卡片通常 1 秒内出结果

## v2.5.8-compat.4（2026-10-03，提交 7064c80）

**建议所有用户安装本版本。**

- **fix(dns)**：内置 DNS 覆写模板（`dns_config.yaml`，首次启动生成）不再以明文 `8.8.8.8` 为首选 nameserver，改为国内 DoH（doh.pub / alidns）优先；并且**默认写入非空 fallback**（同样是国内 DoH）。
  - 原因：DNS 覆写的合并语义是「空值不覆盖订阅值」（`enhance::is_set`），模板 `fallback: []` 盖不掉机场自带的境外 fallback。部分机场 DNS 段带有从国内网络直连不可达的境外 DoH（如 doh.dns.sb / dns.cloudflare.com / tls://8.8.4.4），rule 模式下所有非 CN 域名命中 GEOIP 规则需要本地真实解析时全部挂死。典型症状：首页「IP 信息」卡报 `Request cancelled`；系统代理下访问「新」域名超时，而访问过的域名秒通。
  - ⚠️ 此修复只影响**新生成**的 `dns_config.yaml`。存量用户若遇到上述症状，请手动编辑 `%APPDATA%\io.github.clash-verge-rev.clash-verge-rev\dns_config.yaml`，把 `fallback` 改为 `[https://doh.pub/dns-query, https://dns.alidns.com/dns-query]`（非空才能覆盖订阅值），重启应用生效。
- **fix(unlock)**：「解锁测试」页 ChatGPT / Claude 探测此前不区分 HTTP 状态码——出口 IP 被 Cloudflare 以 403 拦截页拒绝时，ChatGPT 会把拦截页 body 误判为「支持」（假阳性），Claude 则把被封锁误报为「测试失败」。现在 403/451 归类为「不支持」，仅 2xx 响应参与解锁判定，网络层错误仍归类为「测试失败」。
- 服务端与 compat.3 相同（白名单 + 校验上限补丁齐全）。

## v2.5.8-compat.3（2026-10-03，提交 462b98a）

**服务模式修复版，compat.1/2 用户请升级。**

- **fix(service)**：客户端预构建改为打包 dai123x fork 的补丁版服务（内核白名单 + 校验上限补丁齐全），服务模式 / TUN 前置的「安装服务」「修复服务」不再报 `unsupported core name` / `at most two cores`。
- **fix(ci)**：修正发版后附加 zip 步骤的产物路径（仓库根 Cargo workspace 使产物在根 `target/` 而非 `src-tauri/target/`，该步骤自引入起从未成功过）。本版本起 release 同时提供 `_setup.exe` 与 `.zip` 两个资产。

## v2.5.8-compat.2（2026-10-03，提交 36c4c30）

⚠️ **已知问题：内置服务只有白名单补丁、缺校验上限补丁，服务模式点「安装/修复服务」仍会失败，请使用 compat.3+。**

- **fix(service)**：`scripts/service-release.mjs` 改为从 `dai123x/clash-verge-service-ipc` fork 下载补丁版服务二进制（当时仅含白名单补丁）。
- **docs**：新增完整文档 `docs/COMPAT_EDITION.md`（原理、使用、构建、FAQ，fa08722）；README 移除推广与捐赠内容（d9efca4）；补充下载警告指引（b1e8283）。
- **ci**：新增 zip 附加资产步骤（有路径 bug，实际未产出）。

## v2.5.8-compat.1（2026-10-03，提交 96750a8）

**初始版本。已知问题：内置的是上游未打补丁的服务，服务模式不认识兼容内核，请使用 compat.3+。**

- **feat(core)**：新增第三内核 `verge-mihomo-compat`（mihomo v1.19.25，对应官方 v2.5.1 内核时代），解决官方 v2.5.2+ 内核的 Inline Provider 逻辑与 API 变更导致的订阅节点丢失 / Unknown / 解析超时；「设置 → Clash 内核 ⚙」可在 Mihomo / Mihomo Alpha / **Mihomo Compat (v2.5.1)** 间一键切换并自动重启。
- 兼容内核固定版本，不参与「升级内核」（明确提示）。
- **fix(ci)**：compat 构建关闭 `createUpdaterArtifacts` 并清空 updater endpoints（fork 无签名私钥，且防止客户端自动更新回官方版丢失兼容内核）；compat 标签不再触发官方 release 工作流。

---

## 通用注意事项

- **安装**：未签名新文件会有浏览器/SmartScreen 信誉提示（非病毒报告），点「保留」/「更多信息 → 仍要运行」；或直接下载 `.zip` 解压使用。
- **服务模式**：升级客户端后如遇服务不可用，设置页点「修复服务」即可；修复流程走的是本版打包的补丁版安装器，兼容内核会被正常接受。
- **切换内核**：设置 → Clash 内核 → Mihomo Compat (v2.5.1)；遇到订阅节点 Unknown / 解析失败时优先切换此内核。
- **DNS**：如遇「IP 信息」卡 Request cancelled / 新域名经代理超时，见 compat.4 的 `dns_config.yaml` 手动修复说明。
