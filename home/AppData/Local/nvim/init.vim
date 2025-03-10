set runtimepath^=~/.vim runtimepath^=~/.config/nvim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
lua require("config.nvim_init")
