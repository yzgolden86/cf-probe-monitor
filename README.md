# ⚡ CF Probe Monitor

> 基于 Cloudflare Workers + D1 的轻量级服务器监控面板  
> 零成本部署 · 实时监控 · 自动告警 · 全球节点

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Cloudflare Workers](https://img.shields.io/badge/Cloudflare-Workers-orange.svg)](https://workers.cloudflare.com/)

---

## ✨ 核心特性

### 🎯 监控功能
- **实时性能监控**：CPU、内存、磁盘、网络速度、进程数、TCP/UDP 连接
- **三网延迟测试**：电信、联通、移动 + 字节跳动节点延迟追踪
- **流量统计**：支持自然月自动重置，重启不清零
- **历史数据图表**：24小时性能趋势可视化（288个数据点）
- **IPv4/IPv6 检测**：自动识别双栈支持情况
- **虚拟化识别**：自动检测 KVM、OpenVZ、Docker、LXC 等虚拟化类型

### 🎨 界面展示
- **6 套精美主题**：清爽白、暗黑模式、粗野主义、毛玻璃、赛博朋克、自定义 CSS
- **3 种视图模式**：卡片视图、表格视图、地图视图
- **自定义背景**：支持上传图片或填写 URL，自动毛玻璃效果
- **响应式设计**：完美适配桌面端和移动端

### 🔔 告警与管理
- **Telegram 离线告警**：节点离线超过 2 分钟自动推送，恢复时通知
- **分组管理**：支持按地区、用途等自定义分组
- **节点隐藏**：可将测试节点隐藏，不在前台展示
- **资产统计**：自动汇率转换（支持 USD/EUR/GBP/HKD/JPY 等），计算剩余价值

### 🚀 部署优势
- **零成本运行**：Cloudflare 免费套餐足够使用（每日 10 万次请求）
- **全球加速**：依托 Cloudflare CDN，全球访问秒开
- **无需服务器**：Serverless 架构，无需维护
- **一键安装**：Agent 自动安装脚本，支持 Debian/Ubuntu/CentOS/Alpine

---

## 📦 快速部署

### 前置要求
- Cloudflare 账号（免费）
- Wrangler CLI（可选，用于本地开发）

### 方法一：Cloudflare Dashboard 部署（推荐新手）

#### 1. 创建 D1 数据库
```bash
# 登录 Cloudflare Dashboard
# 进入 Workers & Pages > D1 SQL Database
# 点击 "Create database"
# 数据库名称填写：probe-db
```

#### 2. 创建 Worker
```bash
# 进入 Workers & Pages > Overview
# 点击 "Create application" > "Create Worker"
# Worker 名称：cf-probe-monitor（可自定义）
```

#### 3. 部署代码
1. 复制 `probe monitor.js` 的全部内容
2. 在 Worker 编辑器中粘贴代码
3. 点击 "Save and Deploy"

#### 4. 绑定数据库
```bash
# 在 Worker 设置页面
# Settings > Variables > D1 Database Bindings
# 点击 "Add binding"
# Variable name: DB
# D1 database: 选择刚才创建的 probe-db
# 点击 "Save"
```

#### 5. 设置环境变量
```bash
# Settings > Variables > Environment Variables
# 添加变量：
# Name: API_SECRET
# Value: 你的密码（用于 Agent 上报和后台登录）
# 点击 "Save"
```

#### 6. 重新部署
点击 "Quick edit" > "Save and Deploy" 使配置生效

---

### 方法二：Wrangler CLI 部署（推荐开发者）

#### 1. 安装 Wrangler
```bash
npm install -g wrangler
wrangler login
```

#### 2. 创建项目
```bash
mkdir cf-probe-monitor
cd cf-probe-monitor

# 创建 wrangler.toml
cat > wrangler.toml << 'EOF'
name = "cf-probe-monitor"
main = "probe monitor.js"
compatibility_date = "2024-01-01"

[[d1_databases]]
binding = "DB"
database_name = "probe-db"
database_id = "你的数据库ID"

[vars]
API_SECRET = "你的密码"
EOF
```

#### 3. 创建 D1 数据库
```bash
wrangler d1 create probe-db

# 复制输出的 database_id，填入 wrangler.toml
```

#### 4. 部署
```bash
# 将 probe monitor.js 放入项目目录
wrangler deploy
```

---

## 🖥️ Agent 安装

### 自动安装（推荐）

#### Linux (Debian/Ubuntu/CentOS)
```bash
# 在后台管理页面复制安装命令，格式如下：
curl -sL https://你的域名/install.sh?os=debian | bash -s 节点ID 密码
```

#### Alpine Linux
```bash
curl -sL https://你的域名/install.sh?os=alpine | sh -s 节点ID 密码
```

### 手动安装

如果自动安装失败，可以手动创建服务：

<details>
<summary>点击展开手动安装步骤</summary>

#### 1. 创建监控脚本
```bash
# 下载脚本
curl -o /usr/local/bin/cf-probe.sh https://你的域名/install.sh?os=debian

# 编辑脚本，填入你的信息
vim /usr/local/bin/cf-probe.sh
# 修改 SERVER_ID 和 SECRET

# 添加执行权限
chmod +x /usr/local/bin/cf-probe.sh
```

#### 2. 创建 Systemd 服务（Debian/Ubuntu/CentOS）
```bash
cat > /etc/systemd/system/cf-probe.service << 'EOF'
[Unit]
Description=Cloudflare Worker Probe Agent
After=network.target

[Service]
ExecStart=/usr/local/bin/cf-probe.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cf-probe.service
systemctl start cf-probe.service
```

#### 3. 创建 OpenRC 服务（Alpine）
```bash
cat > /etc/init.d/cf-probe << 'EOF'
#!/sbin/openrc-run
name="cf-probe"
command="/usr/local/bin/cf-probe.sh"
command_background="yes"
pidfile="/run/cf-probe.pid"
EOF

chmod +x /etc/init.d/cf-probe
rc-update add cf-probe default
rc-service cf-probe start
```

</details>

---

## ⚙️ 配置说明

### 后台管理
访问 `https://你的域名/admin`，使用 `admin` 和你设置的 `API_SECRET` 登录。

### 全局设置

#### 主题配置
- **清爽白**：默认主题，适合日常使用
- **暗黑模式**：护眼深色，适合夜间查看
- **粗野主义**：复古扁平风格
- **毛玻璃**：紫色渐变 + 毛玻璃效果
- **赛博朋克**：霓虹绿科技风
- **自定义 CSS**：完全自由定制

#### 上报间隔
- 默认 5 秒，建议根据节点数量调整
- 节点较多时建议设置为 60-100 秒，避免超出 Worker 请求限制

#### 流量统计
- **关闭自动重置**：累计从安装开始的总流量（重启会清零）
- **开启自动重置**：每月 1 号自动重置，重启不清零

#### Telegram 告警
1. 创建 Bot：与 [@BotFather](https://t.me/BotFather) 对话，发送 `/newbot`
2. 获取 Token：格式如 `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`
3. 获取 Chat ID：与 [@userinfobot](https://t.me/userinfobot) 对话，获取你的 ID
4. 在后台填入 Token 和 Chat ID，开启告警

#### 三网延迟节点
- 默认使用双栈多节点轮询
- 可自定义指定省份/城市的测速节点
- 支持 IPv4 和双栈节点

---

## 🎨 自定义

### 自定义背景
1. 在后台上传图片或填写图片 URL
2. 系统自动应用毛玻璃效果
3. 清空输入框并保存即可恢复纯色主题

### 自定义 CSS
选择"自定义 CSS"主题，在文本框中编写样式：
```css
body.theme6 {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
.theme6 .vps-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
}
```

### 自定义 Script
可在底部注入自定义 JavaScript，实现高级功能：
```javascript
<script>
// 示例：自动刷新间隔改为 10 秒
setInterval(() => location.reload(), 10000);
</script>
```

---

## 🔒 安全建议

### 基础防护
- ✅ 已内置 IP 速率限制（2秒/次）
- ✅ 已内置 API_SECRET 验证
- ✅ 已内置自动缓存清理

### 进阶防护
1. **启用 Cloudflare Access**：为 `/admin` 路径添加身份验证
2. **启用 WAF 规则**：防止恶意扫描和攻击
3. **定期更换密码**：建议每月更换 API_SECRET
4. **监控请求量**：在 Cloudflare Dashboard 查看异常流量

---

## 📊 数据库说明

### 数据库名称
- **推荐名称**：`probe-db`（与原部署保持一致）
- 如需修改，请同步更新 `wrangler.toml` 中的 `database_name`

### 表结构
系统会自动创建以下表：
- `servers`：服务器信息和监控数据
- `settings`：全局配置

### 数据迁移
如果需要从旧数据库迁移：
```bash
# 导出旧数据
wrangler d1 execute 旧数据库名 --command "SELECT * FROM servers" --json > backup.json

# 导入新数据库
wrangler d1 execute probe-db --file=backup.sql
```

---

## 🐛 常见问题

### Agent 无法连接
1. 检查 Worker 是否正常运行
2. 检查 API_SECRET 是否正确
3. 检查服务器网络是否正常
4. 查看日志：`journalctl -u cf-probe -f`（Systemd）或 `rc-service cf-probe status`（OpenRC）

### 三网延迟显示超时
- 如果 VPS 的 IPv4 被墙或网络不通，延迟会显示为 2000ms 或 2001ms
- 可在后台切换到其他测速节点

### Worker 请求超限
- 免费套餐每日 10 万次请求
- 建议增大上报间隔（60-100 秒）
- 或升级到 Workers Paid 套餐（$5/月，1000 万次请求）

### 数据库写入失败
- 检查 D1 数据库绑定是否正确
- 检查 `database_id` 是否填写正确
- 重新部署 Worker

---
### 开发环境
```bash
# 克隆项目
git clone https://github.com/yzgolden86/cf-probe-monitor.git
cd cf-probe-monitor

# 本地开发
wrangler dev

# 部署到生产
wrangler deploy
```

---

## 📄 许可证

[MIT License](LICENSE)

---

## 🙏 致谢

- [Cloudflare Workers](https://workers.cloudflare.com/) - Serverless 平台
- [Leaflet](https://leafletjs.com/) - 地图库
- [Chart.js](https://www.chartjs.org/) - 图表库
- [Flagcdn](https://flagcdn.com/) - 国旗图标
- [CF-Server-Monitor-Pro](https://github.com/a63414262/CF-Server-Monitor-Pro) - 在此仓库上进行整合和修改

---

<div align="center">
  <sub>Built with ❤️ by yzgolden86</sub>
</div>
