# Minuet AI 代码补全（Grok）

Copilot 式虚拟文本补全，通过 minuet-ai.nvim 接入 xAI Grok。

## 配置

- 插件：`lua/config/plugins/minuet.lua`
- Provider：`openai_compatible` → `https://api.x.ai/v1/chat/completions`
- 模型：`grok-build-0.1`（低成本高速度）
- API Key：环境变量 `XAI_API_KEY`（minuet 按名读取，不填明文）
- `max_tokens = 256`，`throttle = 1500`，`debounce = 600`（控成本/降频）

## 键位

注意：左边 Alt/Ctrl 已互换，因此以下 `<A-*>` 实际按 **物理 Ctrl 键**；右 Alt 未互换也可触发。

| 动作 | 按键 | 物理按键 |
|------|------|----------|
| 采纳整段 | `<A-t>` | 物理 Ctrl+t |
| 采纳单行 | `<A-d>` | 物理 Ctrl+d |
| 下一个建议 | `<A-j>` | 物理 Ctrl+j |
| 上一个建议 | `<A-k>` | 物理 Ctrl+k |
| 关闭建议 | `<A-h>` | 物理 Ctrl+h |

## 设计约束

- 避开 tmux `-n M-*` 全局拦截（a/g/s/r/w/b/n/e/u/i/o/f/l/y/v/1-9 等），这些键按下去会被 tmux 吞掉，不会传到 nvim。
- `<Tab>` 留给 blink.cmp，不冲突。
- 全配置此前无任何 `<A-*>` 映射，本组键位无冲突。

## 改键位时注意

新键必须是：
1. 不在 tmux `-n M-*` 集合里；
2. nvim 插入模式下无占用；
3. 避免物理 Ctrl+c/z 等信号键。

候选空闲键：`c d h j k p t x z ; , . /`。