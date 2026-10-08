set runtimepath^=~/.vim runtimepath^=~/.config/nvim runtimepath+=~/.vim/after runtimepath+=~/.config/nvim/after
let &packpath = &runtimepath
source ~/.vimrc
lua require("config.nvim_init")
