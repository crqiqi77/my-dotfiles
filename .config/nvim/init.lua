vim.opt.number = true
vim.opt.cursorline = true
vim.opt.listchars = { tab = "→ ", trail = "·" }
vim.opt.list = true
--vim.opt.tabstop = 4
--vim.opt.shiftwidth = 4
vim.g.mapleader = " "
vim.g.maplocalleader = " "
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
        { src = "https://github.com/morhetz/gruvbox" },
        { src = "https://github.com/akinsho/bufferline.nvim" },
        { src = "https://github.com/nvim-lualine/lualine.nvim" },
        { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim' },
        { src = 'https://github.com/nvim-lua/plenary.nvim' },
        { src = 'https://github.com/MunifTanjim/nui.nvim' },
        { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
        { src = "https://github.com/neovim/nvim-lspconfig" },
        { src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
        { src = "https://github.com/saghen/blink.cmp" },
        { src = "https://github.com/stevearc/conform.nvim" },
        { src = "https://github.com/nvim-telescope/telescope.nvim" },
        { src = "https://github.com/folke/which-key.nvim" },
        { src = "https://github.com/moll/vim-bbye" },
})

vim.cmd("colorscheme gruvbox")

vim.opt.termguicolors = true
require("bufferline").setup({
})

require('lualine').setup({
        sections = {
                lualine_c = { { "filename", path = 3, symbols = { modified = "[+]", readonly = "[-]", unnamed = "[No Name]", } } }
        }
})

-- 自动关闭 Neo-tree 以防止退出阻塞
vim.api.nvim_create_autocmd("QuitPre", {
        pattern = "*",
        callback = function()
                -- 获取所有窗口
                local wins = vim.api.nvim_list_wins()
                local neo_tree_windows = {}

                -- 找出所有 Neo-tree 窗口
                for _, win in ipairs(wins) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                        if ft == "neo-tree" then
                                table.insert(neo_tree_windows, win)
                        end
                end

                -- 关闭所有 Neo-tree 窗口
                for _, win in ipairs(neo_tree_windows) do
                        vim.api.nvim_win_close(win, false) -- false = 不强制
                end

                -- 短暂延迟，确保窗口关闭完成
                vim.defer_fn(function() end, 50)
        end,
})

vim.lsp.enable({ "lua_ls", "clangd" })

require("tiny-inline-diagnostic").setup({})
vim.diagnostic.config({ virtual_text = false })

-- 关键：在setup中指定使用Lua引擎
vim.api.nvim_create_autocmd('User', {
        pattern = 'BlinkCmpSetup',
        callback = function()
                require('blink.cmp').setup({
                        fuzzy = {
                                implementation = "prefer_rust_with_warning" -- 明确使用Lua实现
                        }
                })
        end
})

require("blink.cmp").setup({
        keymap = { preset = "enter" },
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
