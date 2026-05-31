# cf-probe-monitor

<div align="center">

**基于 Cloudflare Workers 的轻量级服务器监控探针**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Cloudflare Workers](https://img.shields.io/badge/Cloudflare-Workers-orange.svg)](https://workers.cloudflare.com/)
[![GitHub Stars](https://img.shields.io/github/stars/yzgolden86/cf-probe-monitor?style=social)](https://github.com/yzgolden86/cf-probe-monitor)

[English](README_EN.md) | 简体中文

</div>

---

## ✨ 特性

- 🚀 **零成本部署** - 完全基于 Cloudflare Workers 免费套餐
- 📊 **实时监控** - CPU、内存、磁盘、网络、进程等全方位监控
- 🌍 **三网延迟** - 自动测试电信/联通/移动/字节跳动网络延迟
- 🎨 **5 套主题** - 默认清爽、暗黑模式、新粗野主义、毛玻璃、赛博朋克
- ✨ **精致美化** - 现代化设计系统，流畅动画，GPU 加速
- 📱 **响应式设计** - 完美适配桌面端和移动端
- 🔔 **Telegram 告警** - 节点离线自动推送通知
- 📈 **历史图表** - 24 小时性能趋势可视化
- 🗺️ **地图视图** - 全球节点分布一目了然
- 💰 **资产管理** - 支持多币种自动换算 CNY
- 🔐 **访问控制** - 支持公开/私密模式切换

### 🎨 最新美化升级 (v1.0)

本版本对前端界面进行了全面美化升级，主要改进：

- **设计系统** - 7 级阴影系统，优化的圆角，10 个流畅动画
- **视觉效果** - 渐变背景，多层效果，闪光动画，发光阴影
- **交互体验** - 增强的 hover 效果，弹性动画，彩色指示条
- **性能优化** - GPU 加速，60fps 流畅运行，无性能损失

📖 详细改进请查看：[UI_IMPROVEMENTS.md](./UI_IMPROVEMENTS.md) | [DESIGN_PREVIEW.md](./DESIGN_PREVIEW.md)

---

## 📸 界面预览

### 默认主题（清爽白）
现代化卡片设计，毛玻璃效果，渐变色点缀

### 暗黑模式（GitHub Dark）
护眼暗色调，适合长时间监控

### 新粗野主义（Brutalism）
大胆的黑色边框，扁平化设计，复古未来感

### 毛玻璃（Glassmorphism）
紫色渐变背景，半透明卡片，科技感十足

### 赛博朋克（Cyberpunk）
霓虹绿主色调，终端风格，极客最爱

---

## 🚀 快速开始

### 1. 部署到 Cloudflare Workers

#### 方式一：Wrangler CLI（推荐）

```bash
# 克隆仓库
git clone https://github.com/yzgolden86/cf-probe-monitor.git
cd cf-probe-monitor

# 安装 Wrangler
npm install -g wrangler

# 登录 Cloudflare
wrangler login

# 创建 D1 数据库
wrangler d1 create probe-monitor-db

# 复制输出的 database_id，编辑 wrangler.toml
# [[d1_databases]]
# binding = "DB"
# database_name = "probe-monitor-db"
# database_id = "你的database_id"

# 部署
wrangler deploy
```

#### 方式二：Web 界面部署

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 进入 **Workers & Pages** → **Create Application** → **Create Worker**
3. 复制 `probe monitor.js` 的内容粘贴到编辑器
4. 点击 **Save and Deploy**
5. 进入 **Settings** → **Variables** → 添加环境变量：
   - `API_SECRET`: 设置管理密码（必填）
6. 创建 D1 数据库：
   - 进入 **Storage** → **D1** → **Create Database**
   - 数据库名称：`probe-monitor-db`
   - 绑定到 Worker：变量名 `DB`

### 2. 安装探针到服务器

访问 `https://你的worker域名.workers.dev/admin`，使用用户名 `admin` 和你设置的 `API_SECRET` 登录。

#### Linux (Debian/Ubuntu/CentOS)

```bash
curl -sL https://你的worker域名.workers.dev/install.sh?os=debian | bash -s 服务器ID 你的API_SECRET
```

#### Alpine Linux

```bash
curl -sL https://你的worker域名.workers.dev/install.sh?os=alpine | sh -s 服务器ID 你的API_SECRET
```

> **提示**：服务器 ID 和安装命令可在后台管理页面直接复制

---

## 📖 功能说明

### 设计令牌系统（Design Tokens）

本项目采用现代化的设计令牌系统，所有视觉样式通过 CSS 变量统一管理：

```css
:root {
  /* 颜色系统 */
  --color-primary: #3b82f6;      /* 主色调 */
  --color-success: #10b981;      /* 成功/在线 */
  --color-warning: #f59e0b;      /* 警告 */
  --color-danger: #ef4444;       /* 危险/离线 */
  
  /* 圆角系统 */
  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-full: 9999px;
  
  /* 阴影系统 */
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.1);
  --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
  
  /* 缓动函数 */
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

**优势**：
- 🎨 全局一致的视觉风格
- 🔧 易于定制和扩展
- 📦 主题切换无需重写 CSS
- ♿ 更好的可访问性支持

### 三网延迟测试

系统内置 300+ 国内测速节点，支持：
- 电信（CT）：默认北京/上海/广州三地轮询
- 联通（CU）：默认北京/上海/广州三地轮询
- 移动（CM）：默认北京/上海/广州三地轮询
- 字节跳动（BD）：固定节点

可在后台自定义选择省市级测速节点，支持 IPv4 和双栈节点。

### 流量统计模式

- **累计模式**（默认）：统计服务器启动以来的总流量
- **月度重置模式**：每月 1 号自动重置，统计当月流量

### 数字资产管理

支持多币种价格输入，自动换算为人民币：
- 美元（USD/$）：汇率 7.23
- 欧元（EUR/€）：汇率 7.85
- 英镑（GBP/£）：汇率 9.12
- 港币（HKD）：汇率 0.92
- 日元（JPY）：汇率 0.048
- 更多币种...

自动计算剩余价值：`剩余价值 = (总价 / 周期天数) × 剩余天数`

### Telegram 告警

配置 Bot Token 和 Chat ID 后，节点离线超过 2 分钟自动推送：

```
⚠️ 节点离线告警

节点名称: 香港 CN2
状态: 离线 (超过2分钟未上报)
时间: 2024-01-15 14:30:25
```

恢复在线后自动推送恢复通知。

---

## ⚙️ 配置说明

### 环境变量

| 变量名 | 必填 | 说明 | 示例 |
|--------|------|------|------|
| `API_SECRET` | ✅ | 管理密码 | `your-secret-password` |

### 后台设置

访问 `/admin` 进入管理后台：

#### 全局设置
- **前端主题**：5 套预设主题 + 自定义 CSS
- **自定义背景**：支持上传图片或填写 URL
- **自定义 Head**：注入外部字体/CSS
- **自定义 Script**：注入自定义 JS 代码
- **上报间隔**：默认 5 秒（建议 60-100 秒以节省请求次数）

#### 展示控制
- 公开访问 / 密码保护
- 显示价格 / 到期时间
- 显示带宽 / 流量配额徽章
- 数字资产统计
- 每月流量重置

#### Telegram 告警
- 开启/关闭离线通知
- Bot Token
- Chat ID

#### 三网测速节点
- 电信节点选择
- 联通节点选择
- 移动节点选择

---

## 🔧 高级功能

### 自定义主题

选择 **主题 6 - 完全自定义 CSS**，在文本框中输入：

```css
body.theme6 {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
.theme6 .vps-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
}
```

### 自定义背景图

1. 准备一张图片（建议 < 500KB）
2. 上传到图床或使用本地上传
3. 填写图片 URL 到 **自定义背景图片** 输入框
4. 保存后所有卡片自动变为半透明毛玻璃效果

### 隐藏节点

编辑服务器时，将 **前台可见性** 设置为 **隐藏**，该节点不会在前台大盘显示，但仍会继续上报数据。

### 热重载配置

修改上报间隔或测速节点后，无需重启探针，下次心跳（几秒内）自动生效。

---

## 📊 性能优化

### Cloudflare Workers 限制

免费套餐限制：
- 每天 100,000 次请求
- 单次请求 CPU 时间 10ms
- 单次请求内存 128MB

### 优化建议

1. **增大上报间隔**：如果监控节点较多（> 20 台），建议将上报间隔设置为 60-100 秒
2. **使用批量操作**：后台保存设置已优化为批量写入，减少数据库调用
3. **启用浏览器缓存**：静态资源（国旗图标、地图数据）自动缓存
4. **异步告警**：Telegram 通知使用 `ctx.waitUntil()` 异步执行，不阻塞主流程

### 请求次数估算

假设有 N 台服务器，上报间隔 T 秒：

```
每日请求数 = N × (86400 / T) × 1.2
```

示例：
- 10 台服务器，5 秒间隔：`10 × 17280 × 1.2 = 207,360` ❌ 超限
- 10 台服务器，60 秒间隔：`10 × 1440 × 1.2 = 17,280` ✅ 安全
- 50 台服务器，100 秒间隔：`50 × 864 × 1.2 = 51,840` ✅ 安全

---

## 🛠️ 故障排查

### 探针无法连接

1. 检查服务器是否能访问 Cloudflare：`curl -I https://cloudflare.com`
2. 检查 Worker 域名是否正确
3. 检查 API_SECRET 是否匹配
4. 查看探针日志：`journalctl -u cf-probe -f`（Systemd）或 `rc-service cf-probe status`（OpenRC）

### 三网延迟显示超时

- IPv4 被墙或网络不通会显示 2000ms 超时
- 尝试切换其他省份的测速节点
- 检查服务器防火墙是否拦截出站 HTTP 请求

### 数据不更新

- 检查探针服务是否运行：`systemctl status cf-probe`
- 检查服务器时间是否正确：`date`
- 检查 Worker 日志（Cloudflare Dashboard → Workers → Logs）

### 后台保存慢

- 已优化为批量写入，正常情况下 < 1 秒
- 如果仍然慢，检查 D1 数据库是否正常
- 尝试清空浏览器缓存

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发指南

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交更改：`git commit -m 'Add some AmazingFeature'`
4. 推送到分支：`git push origin feature/AmazingFeature`
5. 提交 Pull Request

### 代码规范

- 使用 2 空格缩进
- 遵循 ESLint 规则
- 添加必要的注释
- 保持向后兼容

---

## 📄 开源协议

本项目采用 [MIT License](LICENSE) 开源协议。

---

## 🙏 致谢

- [Cloudflare Workers](https://workers.cloudflare.com/) - 提供免费的边缘计算平台
- [Leaflet](https://leafletjs.com/) - 开源地图库
- [Chart.js](https://www.chartjs.org/) - 图表可视化
- [Flagcdn](https://flagcdn.com/) - 国旗图标 API

---

## 📮 联系方式

- GitHub Issues: [提交问题](https://github.com/yzgolden86/cf-probe-monitor/issues)
- Email: yzgolden86@gmail.com

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

Made with ❤️ by [yzgolden86](https://github.com/yzgolden86)

</div>
