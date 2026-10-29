# navicat-trial-reset

Navicat Premium 试用期重置脚本，支持 macOS / Windows，每个平台的脚本均为单文件、无外部依赖。仅供学习研究，请支持正版：[Navicat Premium](https://www.navicat.com.cn/download/navicat-premium)。

## 特性

- 按存储结构规律清理，试用记录键名不写死（Windows 侧仅保留少量兼容旧版的固定键名）
- 只删除试用状态，数据库连接、查询历史和界面设置全部保留
- 无需管理员 / sudo 权限，无需重启电脑

## 使用

### macOS

- 双击 `mac/reset_navicat_universal.command`
- 或执行 `sh mac/reset_navicat_universal.sh [应用显示名]`，不传参数时默认为 `Navicat Premium`

首次双击 `.command` 若提示“无法验证开发者”，右键 → 打开 → 再次点打开即可。

### Windows

双击 `windows/reset_navicat_universal.bat`。

脚本会先结束所有 Navicat 进程再清理，运行前请保存工作。完成后重新打开 Navicat，即为新的 14 天试用期。

## 重置范围

### macOS

- `~/Library/Preferences/com.navicat.NavicatPremium.plist`：删除顶层 32 位大写 hex 键（试用记录主/备、状态快照）
- `~/Library/Application Support/PremiumSoft CyberTech/Navicat CC/Navicat Premium/`：删除 `.<32hex>` 且恰为 32 字节的隐藏 token 文件
- 清理前先结束 cfprefsd，防止偏好缓存把旧值写回

### Windows

- `HKCU\Software\Classes\CLSID`（含 WOW6432Node）：删除含 `Info` 值、或 `ShellFolder` 指向 Navicat / PremiumSoft 的子键（16/17/18 的试用计时在此，Navicat 重启后自动重建）
- `HKCU\Software\PremiumSoft\NavicatPremium`：清空 `Registration` + 数字子键的所有值（PreTrial 试用记录）；删除 32 位大写 hex 子键（v12~15）；删除 `Update` 子键（仅更新缓存，自动重建）
- `%APPDATA%\PremiumSoft CyberTech\Navicat CC\Navicat Premium`：删除 `.<32hex>` 且 32 字节的隐藏 token 文件

## 已验证版本

| Navicat 版本 | 结果 |
|---|---|
| 18.0.3 | macOS / Windows 10 实测通过 |

其他版本未逐一验证。脚本按存储结构工作，通常同样可用；验证后可在表中补充。重置无效请提 issue。

## 致谢

思路来自 [pretend-m/navicat_for_mac_reset](https://github.com/pretend-m/navicat_for_mac_reset)。

## License

[MIT](LICENSE)
