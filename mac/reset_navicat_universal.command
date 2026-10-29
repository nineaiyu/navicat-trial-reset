#!/bin/bash
# =============================================================
# reset_navicat_universal.command
# Navicat Premium 试用期重置（macOS 双击运行版）
#
# 处理流程：
#   1. 退出所有 Navicat 进程
#   2. 结束偏好缓存守护进程 cfprefsd
#   3. 删除 plist 顶层的 32 位大写 hex 键（试用记录主/备、状态快照）
#   4. 删除数据目录下的隐藏 token 文件（.<32hex> 且 32 字节）
#
# 首次双击若提示“无法验证开发者”：右键 → 打开 → 再次点打开即可。
# 无需 sudo，不会改动数据库连接、查询历史和界面设置。
# =============================================================

PLIST="$HOME/Library/Preferences/com.navicat.NavicatPremium.plist"
APP_SUPPORT="$HOME/Library/Application Support/PremiumSoft CyberTech/Navicat CC/Navicat Premium"
TOKEN_GLOB='.????????????????????????????????'

echo "=== Navicat 试用期重置（macOS） ==="
echo

# [1/4] 退出所有 Navicat 应用（自动探测 /Applications 下的应用名）
echo "[1/4] 退出 Navicat…"
for APP in /Applications/Navicat*.app; do
  [ -d "$APP" ] || continue
  osascript -e "quit app \"$(basename "$APP" .app)\"" 2>/dev/null
done

# 按进程名匹配：脚本路径/文件名含 navicat，用 -f 匹配全命令行会命中脚本自身
for _ in {1..10}; do
  pgrep -i "Navicat" >/dev/null || break
  sleep 1
done
# 兜底：结束所有残留 Navicat 进程（兼容 Premium / Premium 2 / Lite 等命名）
if pgrep -i "Navicat" >/dev/null; then
  pkill -i "Navicat"
  sleep 2
fi
echo "    已退出"

# [2/4] 清理偏好缓存
echo "[2/4] 清理偏好缓存（cfprefsd）…"
killall cfprefsd 2>/dev/null && sleep 1
echo "    已清理"

# [3/4] 删除 plist 加密状态键
echo "[3/4] 清理 plist 状态键…"
if [ ! -f "$PLIST" ]; then
  echo "    未找到 plist，跳过"
else
  KEYS=$(plutil -p "$PLIST" | grep -oE '^  "[0-9A-F]{32}"' | tr -d '" ')
  if [ -z "$KEYS" ]; then
    echo "    无匹配键，跳过"
  else
    COUNT=0
    while IFS= read -r KEY; do
      [ -z "$KEY" ] && continue
      if /usr/libexec/PlistBuddy -c "Delete :$KEY" "$PLIST" 2>/dev/null; then
        echo "    已删除：$KEY"
        COUNT=$((COUNT + 1))
      fi
    done <<< "$KEYS"
    echo "    共清理 $COUNT 个键（明文设置未改动）"
  fi
fi

# [4/4] 删除应用实例 token
echo "[4/4] 清理隐藏 token 文件…"
if [ ! -d "$APP_SUPPORT" ]; then
  echo "    未找到数据目录，跳过"
else
  COUNT=$(find "$APP_SUPPORT" -maxdepth 1 -type f -size 32c \
    -name "$TOKEN_GLOB" 2>/dev/null | wc -l | tr -d ' ')
  find "$APP_SUPPORT" -maxdepth 1 -type f -size 32c \
    -name "$TOKEN_GLOB" -delete 2>/dev/null
  echo "    已删除 $COUNT 个"
fi

echo
echo "完成，重新打开 Navicat 即为新的 14 天试用期。"
echo
read -r -p "按回车键关闭窗口…" _
