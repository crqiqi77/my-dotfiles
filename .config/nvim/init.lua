vim.opt.number = true
vim.opt.cursorline = true
vim.opt.listchars = { tab = "→ ", trail = "·" }
vim.opt.list = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.colorcolumn = "80"
-- 打开文件时，自动跳转到上次编辑位置
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		-- 检查 mark 是否有效（避免跳转到不存在的行）
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.pack.add({
	{ src = "https://github.com/folke/tokyonight.nvim" },
	{ src = "https://github.com/akinsho/bufferline.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = 'https://github.com/nvim-tree/nvim-tree.lua' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
})

vim.cmd [[colorscheme tokyonight]]

vim.opt.termguicolors = true
require("bufferline").setup({
})

require('lualine').setup({
	sections = {
		lualine_c = { { "filename", path = 3, symbols = { modified = "[+]", readonly = "[-]", unnamed = "[No Name]", } } }
	}
})

-- nvim-tree
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- optionally enable 24-bit colour
vim.opt.termguicolors = true
require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},

	-- 自动定位当前文件
	update_focused_file = {
		enable = true,
		update_root = false, -- 为 true 时会随着文件改变工作目录
	},
	-- 自动展开目录树
	renderer = {
		root_folder_modifier = ":t", -- 只显示最后一级目录名
		indent_markers = {
			enable = true, -- 显示缩进标记，便于看清层级
		},
	},
	view = {
		-- 打开文件时自动折叠其他无关部分，聚焦当前文件
		adaptive_size = false,
		side = "left",
		width = 35,
	},
})

vim.lsp.enable({ "lua_ls", "clangd" })

require("tiny-inline-diagnostic").setup({})
vim.diagnostic.config({ virtual_text = false })

-- 关键：在setup中指定使用Lua引擎
require('blink.cmp').setup({
	keymap = {
		preset = "enter",
		["<C-e>"] = require("blink.cmp").abort -- 另一种常见的关闭键
	},
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = { documentation = { auto_show = false } },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
})


require("conform").setup({
	formatters_by_ft = {
		c = { "clang_format" },
	},
	formatters = {
		clang_format = {
			args = { "-style=file" }, -- 使用明确的参数
		},
	},
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- 创建 LspAttach 自动命令
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', {}),
	callback = function(args)
		-- 获取 LSP 客户端和缓冲区编号
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bufnr = args.buf

		-- 创建局部变量 opts，避免作用域问题
		local opts = { buffer = bufnr, remap = false, desc = "LSP: " }

		-- ====================
		-- 基础跳转快捷键
		-- ====================
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
			vim.tbl_extend('force', opts, { desc = '转到定义' }))

		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
			vim.tbl_extend('force', opts, { desc = '转到声明' }))

		vim.keymap.set('n', 'gr', vim.lsp.buf.references,
			vim.tbl_extend('force', opts, { desc = '查找引用' }))

		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,
			vim.tbl_extend('force', opts, { desc = '转到实现' }))

		vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition,
			vim.tbl_extend('force', opts, { desc = '类型定义' }))

		-- ====================
		-- 代码操作快捷键
		-- ====================
		-- 使用新语法检查客户端能力
		if client and client:supports_method('textDocument/codeAction') then
			vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action,
				vim.tbl_extend('force', opts, { desc = '代码操作' }))
		end

		if client and client:supports_method('textDocument/rename') then
			vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,
				vim.tbl_extend('force', opts, { desc = '重命名符号' }))
		end

		-- ====================
		-- 格式化和诊断
		-- ====================
		vim.keymap.set(
			{ "n" },
			"<leader>cf",
			function()
				require("conform").format({
					async = true,
					lsp_fallback = true,
					timeout_ms = 500,
				})
			end,
			{ desc = "Format file" }
		)

		vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
			vim.tbl_extend('force', opts, { desc = '显示诊断信息' }))

		vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
			vim.tbl_extend('force', opts, { desc = '上一个诊断' }))

		vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
			vim.tbl_extend('force', opts, { desc = '下一个诊断' }))

		-- ====================
		-- 悬停和签名帮助
		-- ====================
		vim.keymap.set('n', 'K', vim.lsp.buf.hover,
			vim.tbl_extend('force', opts, { desc = '悬停信息' }))

		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help,
			vim.tbl_extend('force', opts, { desc = '签名帮助' }))

		-- ====================
		-- 工作区管理
		-- ====================
		if client and client:supports_method('workspace/symbol') then
			vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol,
				vim.tbl_extend('force', opts, { desc = '工作区符号' }))
		end
	end
})
