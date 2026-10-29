@echo off
setlocal
rem =============================================================
rem reset_navicat_universal.bat - Navicat Premium 试用期重置（Windows）
rem
rem 处理流程：
rem   1. 结束所有 Navicat 进程
rem   2. 删除 CLSID 下的试用状态子键
rem   3. 清理 NavicatPremium 下的试用记录
rem   4. 删除 AppData 下的隐藏 token 文件
rem
rem 匹配规则：
rem   A. CLSID 下含 Info 值、或 ShellFolder 指向 Navicat / PremiumSoft 的子键
rem   B. Registration + 数字子键，清空所有值（PreTrial 试用记录）
rem   C. 32 位大写 hex 子键（v12~15）
rem   D. Update 子键（仅更新缓存，自动重建）
rem   E. AppData 下 .<32hex> 且 32 字节的隐藏文件
rem
rem 连接、界面等明文设置一律不动。仅依赖系统自带 PowerShell（Win10/11）。
rem PowerShell 书写约定：每行一个引号片段，行尾用续行符，语句以分号收尾。
rem =============================================================
chcp 65001 >nul
title Navicat 试用期重置

echo === Navicat 试用期重置（Windows） ===

echo [1/4] 退出 Navicat…
taskkill /IM Navicat.exe /F >nul 2>&1
taskkill /IM NavicatPremium.exe /F >nul 2>&1
timeout /t 2 /nobreak >nul

rem ---- [2/4] 删除 CLSID 试用状态子键 ----
echo [2/4] 清理 CLSID 状态键…
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$removed = 0;" ^
  "$roots = @('HKCU:\Software\Classes\CLSID', 'HKCU:\Software\Classes\WOW6432Node\CLSID');" ^
  "foreach ($root in $roots) {" ^
  "  if (-not (Test-Path $root)) { continue };" ^
  "  foreach ($key in Get-ChildItem $root -ErrorAction SilentlyContinue) {" ^
  "    $props = Get-ItemProperty -LiteralPath $key.PSPath -ErrorAction SilentlyContinue;" ^
  "    $isNavicat = @($props.PSObject.Properties.Name) -contains 'Info' -or" ^
  "                 [string]$props.ShellFolder -match 'Navicat|PremiumSoft';" ^
  "    if ($props -and $isNavicat) {" ^
  "      Remove-Item -LiteralPath $key.PSPath -Recurse -Force;" ^
  "      $removed++;" ^
  "      Write-Host ('    已删除: ' + $key.PSChildName)" ^
  "    }" ^
  "  }" ^
  "};" ^
  "if ($removed) { Write-Host ('    共清理 ' + $removed + ' 个') } else { Write-Host '    无状态键，跳过' }"

rem ---- [3/4] 清理 NavicatPremium 试用记录 ----
echo [3/4] 清理 NavicatPremium 试用记录…
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$base = 'HKCU:\Software\PremiumSoft\NavicatPremium';" ^
  "if (Test-Path $base) {" ^
  "  if (Test-Path ($base + '\Update')) {" ^
  "    Remove-Item ($base + '\Update') -Recurse -Force;" ^
  "    Write-Host '    已删除: Update'" ^
  "  };" ^
  "  foreach ($key in Get-ChildItem $base) {" ^
  "    $names = (Get-Item -LiteralPath $key.PSPath).GetValueNames();" ^
  "    if ($key.PSChildName -cmatch '^Registration\d' -and $names) {" ^
  "      Remove-ItemProperty -LiteralPath $key.PSPath -Name $names -Force;" ^
  "      Write-Host ('    已清空: ' + $key.PSChildName)" ^
  "    } elseif ($key.PSChildName -cmatch '^[0-9A-F]{32}$') {" ^
  "      Remove-Item -LiteralPath $key.PSPath -Recurse -Force;" ^
  "      Write-Host ('    已删除: ' + $key.PSChildName)" ^
  "    }" ^
  "  }" ^
  "} else { Write-Host '    未找到注册表项，跳过' }"

rem ---- [4/4] 删除 AppData 隐藏 token 文件 ----
echo [4/4] 删除隐藏 token 文件…
set "TOKEN_DIR=%APPDATA%\PremiumSoft CyberTech\Navicat CC\Navicat Premium"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$dir = '%TOKEN_DIR%';" ^
  "if (Test-Path -LiteralPath $dir) {" ^
  "  foreach ($file in Get-ChildItem -LiteralPath $dir -Force -File) {" ^
  "    if ($file.Name -cmatch '^\.[0-9A-F]{32}$' -and $file.Length -eq 32) {" ^
  "      Remove-Item -LiteralPath $file.FullName -Force;" ^
  "      Write-Host ('    已删除: ' + $file.Name)" ^
  "    }" ^
  "  }" ^
  "} else { Write-Host '    未找到数据目录，跳过' }"

echo.
echo 完成！重新打开 Navicat 即为新的 14 天试用期。
pause
