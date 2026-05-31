#!/bin/bash
# Git 推送脚本
# 请在项目根目录执行此脚本

echo "=== cf-probe-monitor Git 推送脚本 ==="
echo ""

# 检查当前目录
if [ ! -f "probe monitor.js" ]; then
    echo "❌ 错误：请在项目根目录执行此脚本"
    exit 1
fi

echo "✅ 当前目录正确"
echo ""

# 检查 Git 状态
echo "📋 检查 Git 状态..."
git status
echo ""

# 提交代码
echo "📝 提交代码..."
git commit -m "feat: initial release of cf-probe-monitor

- Cloudflare Workers based server monitoring probe
- 5 built-in themes (Classic, Dark, Brutalism, Glass, Cyberpunk)
- Real-time CPU/RAM/Disk/Network monitoring
- Three-network latency testing (CT/CU/CM)
- Telegram offline alerts
- 24h historical charts
- World map view
- Digital asset management with multi-currency support
- Design token system for consistent theming
- Batch DB writes for faster settings save
- Responsive design for mobile/desktop
- Custom background image support with auto-overlay

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"

if [ $? -ne 0 ]; then
    echo "❌ 提交失败"
    exit 1
fi

echo "✅ 提交成功"
echo ""

# 添加远程仓库
echo "🔗 添加远程仓库..."
git remote add origin https://github.com/yzgolden86/cf-probe-monitor.git 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ 远程仓库添加成功"
else
    echo "ℹ️  远程仓库已存在，跳过"
fi
echo ""

# 重命名分支为 main
echo "🌿 重命名分支为 main..."
git branch -M main
echo "✅ 分支重命名成功"
echo ""

# 推送到 GitHub
echo "🚀 推送到 GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 推送成功！"
    echo ""
    echo "🎉 项目已成功推送到 GitHub！"
    echo "📦 仓库地址: https://github.com/yzgolden86/cf-probe-monitor"
    echo ""
    echo "📝 后续步骤："
    echo "1. 访问 GitHub 仓库添加描述和 Topics"
    echo "2. 在 Cloudflare Workers 上部署测试"
    echo "3. 截取主题效果图更新到 README"
else
    echo ""
    echo "❌ 推送失败"
    echo "请检查："
    echo "1. GitHub 仓库是否已创建"
    echo "2. Git 凭据是否正确"
    echo "3. 网络连接是否正常"
    exit 1
fi
