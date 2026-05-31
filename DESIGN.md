# 设计系统说明（Design System）

本文档说明 cf-probe-monitor 的前端设计系统，便于二次开发或定制主题。

---

## 什么是「设计令牌」（Design Tokens）

**简单理解：把颜色、间距、阴影等视觉变量统一管理，而不是散落在各处的「魔法数字」。**

### 传统做法（不好）
```css
.button { padding: 12px 18px; background: #3b82f6; border-radius: 8px; }
.card   { padding: 14px 20px; background: #3a82f5; border-radius: 9px; }
.input  { padding: 13px 16px; background: #3c83f7; border-radius: 7px; }
```
看着差不多但每个值都不一样，改一次主题要改 30 个地方。

### 设计令牌做法（好）
```css
:root {
  --color-primary: #3b82f6;
  --space-md: 12px;
  --radius-sm: 8px;
}
.button, .card, .input {
  background: var(--color-primary);
  padding: var(--space-md);
  border-radius: var(--radius-sm);
}
```
改 `--color-primary` 一处，所有按钮/卡片/输入框同步更新。

---

## 项目使用的令牌

所有令牌定义在 [probe monitor.js](probe%20monitor.js) 的 `:root` 选择器内。

### 颜色（Colors）

```css
--color-primary: #3b82f6;       /* 主色（蓝）*/
--color-primary-light: #60a5fa;
--color-primary-dark: #2563eb;
--color-success: #10b981;       /* 在线/成功 */
--color-warning: #f59e0b;       /* 警告 */
--color-danger: #ef4444;        /* 离线/错误 */
--color-purple: #8b5cf6;        /* 装饰渐变 */
--color-pink: #ec4899;
--color-cyan: #06b6d4;

/* 灰阶 — 从最浅到最深 */
--gray-50  到 --gray-900
```

**用法**：永远不要写 `#3b82f6`，写 `var(--color-primary)`。

### 圆角（Radius）

```css
--radius-xs: 4px;    /* 徽章 */
--radius-sm: 8px;    /* 输入框、按钮 */
--radius-md: 12px;   /* 内部卡片 */
--radius-lg: 16px;   /* 主卡片 */
--radius-xl: 24px;
--radius-full: 9999px; /* 胶囊形 */
```

### 阴影（Shadows）

层次越高越「漂浮」：

```css
--shadow-xs   /* 静态徽章 */
--shadow-sm   /* 默认卡片 */
--shadow-md   /* 强调卡片 */
--shadow-lg   /* hover 状态 */
--shadow-xl   /* 弹窗 */
--shadow-2xl  /* 悬浮元素 */
```

### 字体（Typography）

```css
--font-sans: 系统字体栈，正文用
--font-mono: 等宽字体，数字/代码用
```

### 缓动函数（Easing）

```css
--ease-out: cubic-bezier(0.16, 1, 0.3, 1);    /* 标准缓出 */
--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1); /* 弹性 */
--ease-smooth: cubic-bezier(0.4, 0, 0.2, 1);  /* 平滑 */
```

---

## 自定义主题（写自己的 CSS）

后台「主题 6 - 完全自定义 CSS」可以注入你自己的 CSS。例如想改主色为红色：

```css
:root {
  --color-primary: #ef4444;
  --color-primary-light: #f87171;
  --color-primary-dark: #dc2626;
}
```

整站的蓝色立即变红，无需改其他地方。

---

## 内置主题适配性

5 套内置主题对设计令牌的覆盖情况：

| 主题 | 描述 | 适合场景 |
|------|------|----------|
| 1. 默认清爽 | 蓝紫渐变点缀，毛玻璃 | 日常使用、白天 |
| 2. 暗黑极客 | GitHub Dark 配色 | 夜间、长时间监控 |
| 3. 新粗野主义 | 黑边框 + 黄底，硬阴影 | 个性、复古 |
| 4. 渐变毛玻璃 | 紫色渐变 + 透明卡片 | 视觉冲击 |
| 5. 赛博朋克 | 霓虹绿/粉，黑底 | 极客、终端风 |
| 6. 完全自定义 | 你自己写 | 高度定制 |

每套主题通过覆盖 `body.themeN .vps-card { ... }` 等选择器来重定义视觉，而不会破坏布局。

---

## 自定义背景图

后台上传一张图片后，系统会自动在背景图上叠加一层 65% 不透明度的白色蒙版（带 2px 模糊），保证卡片文字始终清晰可读：

```css
body::before {
  content: '';
  position: fixed;
  inset: 0;
  background: linear-gradient(180deg, rgba(255,255,255,0.65), rgba(255,255,255,0.5));
  backdrop-filter: blur(2px);
}
```

所有卡片自动变为半透明毛玻璃（85% 透明度 + 16px 模糊）。

---

## 性能考虑

### 已应用的优化

- **批量数据库写入**：保存设置时使用 `db.batch()` 一次性提交所有更改（原来是 N 次 await）
- **CSS 动画优于 JS 动画**：所有过渡使用 CSS `transition`，不占用 JS 主线程
- **GPU 加速**：使用 `transform` 和 `opacity` 触发 GPU 合成层
- **font-feature-settings**：等宽数字 `tnum` 让数字对齐不抖动
- **-webkit-font-smoothing**：抗锯齿字体渲染

### 建议配置

> 服务器越多，上报间隔应越大。

| 服务器数 | 推荐上报间隔 | 每日 Worker 请求数（10 万限额） |
|----------|-------------|-------------------------------|
| 1-10     | 30-60 秒    | 17,000-35,000  ✅              |
| 11-30    | 60-90 秒    | 34,000-52,000  ✅              |
| 31-50    | 90-120 秒   | 52,000-69,000  ✅              |
| 50+      | 120+ 秒     | 视情况而定                     |

---

## 微交互（Micro-interactions）

| 元素 | 触发 | 效果 |
|------|------|------|
| 卡片 | hover | 上浮 4px + 阴影加深 + 顶部渐变线显示 + 标题变彩色 |
| 进度条 | 加载/更新 | 0.8s 缓动填充 + 顶部高光反射 |
| 状态点 | 在线时 | 2 秒脉动呼吸 |
| 视图切换按钮 | hover | 背景填充 + 图标投影 |
| 筛选标签 | hover | 边框变蓝 + 上浮 1px |
| 管理按钮 | hover | 上浮 2px + 阴影加深 + 渐变切换 |

---

## 开发约定

1. **不写魔法数字**：所有颜色/间距/圆角必须用 `var(--xxx)`
2. **保持节奏**：间距使用 4px / 8px / 12px / 16px / 24px / 32px 这种 4 的倍数
3. **限制字号档位**：整个项目最多 6 个字号（10/11/12/13/14/15/16/18/22/28px）
4. **优先 CSS**：能用 CSS 实现的不要用 JS（动画、过渡、布局）
5. **响应式优先**：所有布局必须在 375px 宽度下可用

---

## 参考

- [Tailwind CSS](https://tailwindcss.com/docs/customizing-colors) — 颜色阶梯参考
- [Radix UI](https://www.radix-ui.com/colors) — 配色系统
- [Cubic-bezier.com](https://cubic-bezier.com) — 缓动函数可视化
- [Open Props](https://open-props.style/) — 设计令牌的另一个范本

---

如有疑问，欢迎提 Issue。
