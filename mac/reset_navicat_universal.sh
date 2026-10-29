#!/bin/bash
# =============================================================
# reset_navicat_universal.sh
# Navicat Premium 试用期重置（macOS 命令行版）
#
# 用法：
#   sh reset_navicat_universal.sh [应用显示名]
#   不传参数时默认为 "Navicat Premium"
#
# 处理流程：
#   1. 退出 Navicat，避免内存状态写回
#   2. 结束偏好缓存守护进程 cfprefsd，防止旧值回写
#   3. 删除 plist 顶层的 32 位大写 hex 键（试用记录主/备、状态快照）
#   4. 删除数据目录下的隐藏 token 文件（.<32hex> 且 32 字节）
#
# 设计原则：不硬编码试用记录的键名/文件名，按存储结构匹配；
#           连接、界面等明文设置不受影响；无需 sudo，无需重启电脑。
# 适配：macOS，Navicat Premium 16.x / 17.x / 18.x（按结构工作）。
# =============================================================

APP_NAME="${1:-Navicat Premium}"

PLIST="$HOME/Library/Preferences/com.navicat.NavicatPremium.plist"
APP_SUPPORT="$HOME/Library/Application Support/PremiumSoft CyberTech/Navicat CC/Navicat Premium"
TOKEN_GLOB='.????????????????????????????????'

# ---------- [1/4] 退出 Navicat ----------
echo "[1/4] 退出 Navicat…"
osascript -e "quit app \"$APP_NAME\"" 2>/dev/null

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

# ---------- [2/4] 清理偏好缓存 ----------
echo "[2/4] 清理偏好缓存（cfprefsd）…"
if killall cfprefsd 2>/dev/null; then
  sleep 1
  echo "    已清理"
else
  echo "    无需清理"
fi

# ---------- [3/4] 删除 plist 加密状态键 ----------
echo "[3/4] 清理 plist 状态键…"
if [ ! -f "$PLIST" ]; then
  echo "    未找到 $PLIST，跳过（可能未安装或为 Lite 版）"
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

# ---------- [4/4] 删除应用实例 token ----------
echo "[4/4] 清理隐藏 token 文件…"
if [ ! -d "$APP_SUPPORT" ]; then
  echo "    未找到 $APP_SUPPORT，跳过"
else
  COUNT=$(find "$APP_SUPPORT" -maxdepth 1 -type f -size 32c \
    -name "$TOKEN_GLOB" 2>/dev/null | wc -l | tr -d ' ')
  find "$APP_SUPPORT" -maxdepth 1 -type f -size 32c \
    -name "$TOKEN_GLOB" -delete 2>/dev/null
  echo "    已删除 $COUNT 个 token（多实例共存时会一并重置，无害）"
fi

echo "完成！打开 $APP_NAME 即为新的 14 天试用期。"
echo "（本脚本按存储结构工作，不依赖具体键名/文件名，可在其他 Mac 上直接使用）"
