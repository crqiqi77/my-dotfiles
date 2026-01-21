vim.opt.number = true
vim.opt.cursorline = true
vim.opt.tabstop = 4     -- 一个 Tab 字符显示为 4 列宽
vim.opt.shiftwidth = 4
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·" }

require("config.lazy")
