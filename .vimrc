set number
set cursorline
set tabstop=4
set autoindent
syntax on
set showtabline=2
set laststatus=2
autocmd BufWritePost $MYVIMRC source $MYVIMRC
set list
set listchars=tab:→\ ,trail:·

call plug#begin('~/.vim/plugged')
" 状态栏 & 标签栏增强
Plug 'vim-airline/vim-airline'
" Git 集成（显示分支/状态）
Plug 'tpope/vim-fugitive'
" 文件图标（可选，需 Nerd Font）
"Plug 'ryanoasis/vim-devicons'
call plug#end()

" === Airline 配置 ===
let g:airline#extensions#tabline#enabled = 1          " 启用顶部标签栏
