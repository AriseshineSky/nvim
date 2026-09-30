# Neovim 配置仓库（lazy.nvim）

本仓库是用户的个人 Neovim 配置，使用 lazy.nvim 管理插件。修改任何配置前先通读本文件。

## 目录结构

```
init.lua                        # 入口：依次加载 defaults / keymaps / plugins / english
lua/config/defaults.lua         # 全局编辑器选项（vim.o / vim.env 等）
lua/config/keymaps.lua          # 全部快捷键映射（leader 为空格，local leader 为逗号）
lua/config/plugins.lua          # lazy.nvim 引导 + 插件注册表（每个插件在 require 列表占一行）
lua/config/plugins/*.lua        # 一个插件一个文件；导出 lazy spec（含 config/keys/opts/dependencies）
lua/config/english.lua          # 拼写检查/英文相关设置
lua/config/machine_specific.lua # 机器特定配置（被 .gitignore 忽略，不入库；如 python 路径、浏览器等）
default_config/_machine_specific_default.lua  # machine_specific.lua 的模板，改模板需同步这里
lsp/*.lua                       # 各语言 LSP 服务器配置（clangd、pyright、ts_ls、ruby-lsp 等）
ftplugin/*.{lua,vim}            # 按文件类型设置（tab/缩进等）
Ultisnips/                      # UltiSnips 代码片段
lazy-lock.json                  # 插件版本锁文件，随 git 提交
```

## 关键约定

- 键盘映射基于 Colemak 布局：`u/e/n/i` 分别映射到 `k/j/h/l`（hjkl）。新增映射时遵守这套布局，不要硬编码标准方向键习惯。
- leader 键是空格（`<leader>` / `<SPC>`），local leader 是逗号（`,`）。
- 插件配置必须放在 `lua/config/plugins/` 下一个独立文件，并在 `lua/config/plugins.lua` 的 `lazy.setup` require 列表中注册，缺一不可。
- 新增 LSP 服务器：在顶层 `lsp/<name>.lua` 写配置并按需接入 `lua/config/plugins/lspconfig.lua`。文件名与项目既有风格（如 `ts_ls.lua`）保持一致。
- 文件类型设置优先放 `ftplugin/`（Lua 或 Vim 脚本皆可，跟随已有文件风格）。
- `machine_specific.lua` 是被 git 忽略的机器专属文件：不要把具体机器路径（home 目录、pyenv、浏览器可执行路径等）硬编码进任何入库文件。
- 仓库使用 git 管理（`/home/sky/.config/nvim`），主要语言是 Lua，遵守既有代码风格（tab 缩进为主，与文件中已有风格一致）。
- 仓库里 `demo.png`、`cursor*.vim`、`.ruby-lsp/`、`.ruff_cache/` 等为历史/缓存内容，不要随意改动。

## 常见任务

- **查看/安装/更新插件**：`<leader>pl`（即 `<SPC>pl`）打开 Lazy 面板；命令行 `:Lazy`。更新后可提交 `lazy-lock.json`。
- **机器特定配置**：把某台机器的私有设置写进 `lua/config/machine_specific.lua`（copy 自 `default_config/_machine_specific_default.lua`），不要在入库文件里引用该文件内容以外的机器路径。
- **改快捷键**：在 `lua/config/keymaps.lua` 的映射表里增加条目（不同模式用 `mode` 字段区分）。
- **验证修改**：每次改动后运行 `nvim --headless -c "q"` 确认无启动报错；插件相关改动可用 `nvim --headless "+Lazy! sync" +q` 类命令做无头检查。

## 给 agent 的工作纪律

- 改动前先读目标文件全文与相邻文件，保持一致风格。
- 只做用户要求的最小改动；不顺手重构无关代码。
- 完成修改后必须验证 nvim 能正常启动（见上）。
- 输出改动摘要时给出具体文件路径。