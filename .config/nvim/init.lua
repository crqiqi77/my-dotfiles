vim.opt.number = true
vim.opt.cursorline = true
--vim.opt.tabstop = 4     -- 一个 Tab 字符显示为 4 列宽
vim.opt.shiftwidth = 4  -- 自动缩进（如 >>、<<）使用 4 空格
--vim.opt.autoindent = true    
--vim.opt.syntax = "on"  
vim.opt.showtabline = 2
--vim.opt.laststatus = 2
--vim.opt.listchars = { tab = "→ ", trail = "·" }    

    
require("config.lazy")

-- init.lua
vim.opt.background = "dark"
vim.cmd("hi Normal ctermbg=NONE guibg=NONE")
vim.cmd("hi NonText ctermbg=NONE guibg=NONE")
    
    
