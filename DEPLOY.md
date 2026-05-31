# 部署指南

本文档详细说明如何将 cf-probe-monitor 部署到 Cloudflare Workers。

## 前置要求

- Cloudflare 账号（免费套餐即可）
- Node.js 16+ 和 npm（使用 Wrangler CLI 时需要）
- Git（可选）

---

## 方式一：使用 Wrangler CLI 部署（推荐）

### 1. 安装 Wrangler

```bash
npm install -g wrangler
```

### 2. 登录 Cloudflare

```bash
wrangler login
```

浏览器会自动打开授权页面，点击允许即可。

### 3. 克隆项目

```bash
git clone https://github.com/yzgolden86/cf-probe-monitor.git
cd cf-probe-monitor
```

### 4. 创建 D1 数据库

```bash
wrangler d1 create probe-monitor-db
```

输出示例：
```
✅ Successfully created DB 'probe-monitor-db'

[[d1_databases]]
binding = "DB"
database_name = "probe-monitor-db"
database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

### 5. 配置 wrangler.toml

复制上面输出的 `database_id`，编辑 `wrangler.toml`：

```toml
[[d1_databases]]
binding = "DB"
database_name = "probe-monitor-db"
database_id = "你的database_id"  # 替换这里
```

### 6. 设置环境变量

编辑 `wrangler.toml`，取消注释并设置密码：

```toml
[vars]
API_SECRET = "your-secret-password"  # 设置你的管理密码
```

或者使用命令行设置（更安全）：

```bash
wrangler secret put API_SECRET
# 输入你的密码
```

### 7. 部署

```bash
wrangler deploy
```

部署成功后会显示 Worker 的 URL：
```
✨ Uploaded cf-probe-monitor
✨ Published cf-probe-monitor
  https://cf-probe-monitor.your-subdomain.workers.dev
```

### 8. 绑定自定义域名（可选）

在 Cloudflare Dashboard 中：
1. 进入 Workers & Pages → 你的 Worker
2. 点击 **Settings** → **Triggers** → **Add Custom Domain**
3. 输入你的域名（如 `monitor.example.com`）
4. 点击 **Add Custom Domain**

---

## 方式二：Web 界面部署

### 1. 创建 D1 数据库

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 左侧菜单选择 **Workers & Pages**
3. 点击 **D1** 标签页
4. 点击 **Create Database**
5. 数据库名称输入：`probe-monitor-db`
6. 点击 **Create**

### 2. 创建 Worker

1. 回到 **Workers & Pages** 主页
2. 点击 **Create Application** → **Create Worker**
3. Worker 名称输入：`cf-probe-monitor`
4. 点击 **Deploy**

### 3. 编辑 Worker 代码

1. 点击 **Edit Code**
2. 删除默认代码
3. 打开本地的 `probe monitor.js` 文件
4. 复制全部内容粘贴到编辑器
5. 点击 **Save and Deploy**

### 4. 绑定 D1 数据库

1. 点击 **Settings** → **Variables**
2. 滚动到 **D1 Database Bindings** 部分
3. 点击 **Add Binding**
4. Variable name: `DB`
5. D1 database: 选择 `probe-monitor-db`
6. 点击 **Save**

### 5. 设置环境变量

1. 在 **Variables** 页面
2. 滚动到 **Environment Variables** 部分
3. 点击 **Add Variable**
4. Variable name: `API_SECRET`
5. Value: 输入你的管理密码
6. 点击 **Encrypt**（推荐）
7. 点击 **Save**

### 6. 重新部署

点击右上角的 **Quick Edit** → **Save and Deploy**

---

## 安装探针到服务器

### 1. 访问管理后台

打开浏览器访问：`https://你的worker域名.workers.dev/admin`

- 用户名：`admin`
- 密码：你设置的 `API_SECRET`

### 2. 添加服务器

1. 在 **节点列表** 部分
2. 输入服务器名称（如：`香港 CN2`）
3. 选择系统环境：
   - **Linux (Systemd)**: Debian/Ubuntu/CentOS/RHEL 等
   - **Alpine (OpenRC)**: Alpine Linux
4. 点击 **+ 添加新服务器**

### 3. 复制安装命令

点击新添加服务器行的 **复制命令** 按钮。

### 4. 在服务器上执行

SSH 登录到你的服务器，粘贴并执行复制的命令：

```bash
# Linux (Systemd)
curl -sL https://你的worker域名.workers.dev/install.sh?os=debian | bash -s 服务器ID 你的API_SECRET

# Alpine Linux
curl -sL https://你的worker域名.workers.dev/install.sh?os=alpine | sh -s 服务器ID 你的API_SECRET
```

### 5. 验证安装

等待 5-10 秒，刷新管理后台页面，服务器状态应该显示为 **在线**。

---

## 配置说明

### 全局设置

访问 `/admin` 后台，在 **全局设置与高级自定义** 部分：

#### 主题设置
- **主题 1 - 默认清爽白**：现代化设计，适合日常使用
- **主题 2 - 暗黑极客**：GitHub Dark 风格，护眼
- **主题 3 - 新粗野主义**：大胆的黑色边框，扁平化
- **主题 4 - 动态渐变毛玻璃**：紫色渐变，科技感
- **主题 5 - 赛博朋克**：霓虹绿，终端风格
- **主题 6 - 完全自定义 CSS**：自己写 CSS

#### 自定义背景
- 支持上传本地图片（建议 < 500KB）
- 或填写图片 URL
- 开启后所有卡片自动变为半透明毛玻璃

#### 上报间隔
- 默认 5 秒
- **重要**：如果服务器较多（> 20 台），建议设置为 60-100 秒
- 计算公式：`每日请求数 = 服务器数 × (86400 / 间隔秒数) × 1.2`
- Cloudflare 免费套餐限制：每天 100,000 次请求

#### 展示控制
- **公开访问**：取消勾选后需要密码才能查看前台
- **显示价格**：在卡片上显示服务器价格
- **显示到期时间**：显示剩余天数
- **显示带宽徽章**：显示带宽标签
- **显示流量配额徽章**：显示流量限制标签
- **数字资产**：统计总价值和剩余价值
- **每月流量重置**：每月 1 号自动重置流量统计

#### Telegram 告警
1. 创建 Telegram Bot：
   - 在 Telegram 中搜索 `@BotFather`
   - 发送 `/newbot` 创建机器人
   - 复制 Bot Token
2. 获取 Chat ID：
   - 在 Telegram 中搜索 `@userinfobot`
   - 发送任意消息获取你的 Chat ID
3. 在后台填写 Bot Token 和 Chat ID
4. 开启离线通知

#### 三网测速节点
- 默认使用北京/上海/广州三地轮询
- 可自定义选择省市级节点
- 支持 IPv4 和双栈节点

---

## 故障排查

### 探针无法连接

**症状**：服务器一直显示离线

**解决方案**：
1. 检查服务器网络：`curl -I https://cloudflare.com`
2. 检查探针服务状态：
   ```bash
   # Systemd
   systemctl status cf-probe
   journalctl -u cf-probe -f
   
   # OpenRC
   rc-service cf-probe status
   ```
3. 检查 Worker URL 和 API_SECRET 是否正确
4. 重新安装探针

### 三网延迟显示超时

**症状**：延迟显示 2000ms 或 2001ms

**原因**：
- IPv4 被墙或网络不通
- 测速节点不可达

**解决方案**：
1. 在后台切换其他省份的测速节点
2. 检查服务器防火墙规则
3. 测试网络连通性：`curl -I http://测速节点域名`

### 数据不更新

**症状**：前台数据长时间不刷新

**解决方案**：
1. 检查探针服务是否运行
2. 检查服务器时间是否正确：`date`
3. 查看 Worker 日志（Dashboard → Workers → Logs）
4. 检查 D1 数据库是否正常

### 后台保存慢

**症状**：点击保存后等待很久才响应

**解决方案**：
- 已优化为批量写入，正常 < 1 秒
- 清空浏览器缓存
- 检查 D1 数据库状态
- 检查网络连接

### 超出免费额度

**症状**：Worker 返回 429 错误

**解决方案**：
1. 增大上报间隔（60-100 秒）
2. 减少监控的服务器数量
3. 升级到 Cloudflare Workers 付费套餐

---

## 性能优化建议

### 1. 合理设置上报间隔

| 服务器数量 | 推荐间隔 | 每日请求数 |
|-----------|---------|-----------|
| 1-10 台   | 30-60 秒 | 17,280-34,560 |
| 11-30 台  | 60-90 秒 | 34,560-51,840 |
| 31-50 台  | 90-120 秒| 51,840-69,120 |
| 50+ 台    | 120+ 秒  | 需计算 |

### 2. 使用自定义域名

绑定自定义域名后，可以享受 Cloudflare CDN 加速，访问速度更快。

### 3. 启用浏览器缓存

前台页面已自动缓存静态资源（国旗图标、地图数据），无需额外配置。

### 4. 定期清理历史数据

历史图表数据保留 24 小时（288 个数据点），自动滚动更新，无需手动清理。

---

## 安全建议

1. **使用强密码**：API_SECRET 建议使用 20+ 位随机字符
2. **启用密码保护**：如果不需要公开访问，取消勾选 **公开访问**
3. **定期更换密码**：建议每 3-6 个月更换一次
4. **使用 HTTPS**：Cloudflare Workers 默认强制 HTTPS
5. **限制访问 IP**：可在 Cloudflare Firewall 中设置 IP 白名单

---

## 更新升级

### 使用 Wrangler CLI

```bash
cd cf-probe-monitor
git pull
wrangler deploy
```

### 使用 Web 界面

1. 下载最新的 `probe monitor.js`
2. 登录 Cloudflare Dashboard
3. 进入你的 Worker → **Quick Edit**
4. 替换代码
5. 点击 **Save and Deploy**

**注意**：更新后无需重新安装探针，配置会自动保留。

---

## 常见问题

### Q: 免费套餐够用吗？

A: 对于个人用户（< 20 台服务器），完全够用。建议将上报间隔设置为 60 秒以上。

### Q: 支持 IPv6 吗？

A: 支持。探针会自动检测 IPv4 和 IPv6 连通性，并在卡片上显示徽章。

### Q: 可以监控 Windows 服务器吗？

A: 目前仅支持 Linux 系统。Windows 支持计划中。

### Q: 数据会丢失吗？

A: D1 数据库会自动备份，但建议定期导出重要数据。

### Q: 可以同时监控多个 Worker 吗？

A: 可以。每个 Worker 独立运行，互不影响。

---

## 技术支持

- GitHub Issues: https://github.com/yzgolden86/cf-probe-monitor/issues
- Email: yzgolden86@gmail.com

---

**祝你使用愉快！如有问题欢迎反馈。**
