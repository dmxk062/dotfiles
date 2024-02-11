filetype on
set noshowmode
filetype plugin on
filetype indent on
syntax on
set number
set termguicolors
set incsearch
set ignorecase
set smartcase
set showcmd
set hlsearch
set wildmenu
set wildmode=list:longest
set expandtab
set tabstop=4
set shiftwidth=4
source ~/.config/nvim/pkgs.vim
lua require('luaconf')
colorscheme nord
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
let g:nord_italic = v:true
let g:nord_borders = v:true



let mapleader = ","
noremap Wj <c-w>j 
noremap Wk <c-w>k
noremap Wh <c-w>h
noremap Wl <c-w>l
noremap WJ <c-w>J 
noremap WK <c-w>K
noremap WH <c-w>H
noremap WL <c-w>L
inoremap <C-h> <LEFT>
inoremap <C-j> <DOWN>
inoremap <C-k> <UP>
inoremap <C-l> <RIGHT>
" imap <C-s> <Esc>[s1z=`]a
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <C-h> :tabprevious<CR>
noremap <C-L> :tabnext<CR>
noremap <leader>+ :tabnew<CR>
noremap <leader>t :tabnew<CR>
noremap <leader>[ :vsplit<CR>
noremap <leader>] :vsp 
noremap <leader>' :sp 
" dont clear registers on change
vnoremap <a-y> "+y<ESC>
vnoremap <a-p> "+p<ESC>

" noremap <leader>l :Lf  <CR> 
noremap <leader>F :FZF<CR>
noremap q :q<CR>
cab mo :set mouse=a
cab mf :set mouse=
cab spde :setlocal spell spelllang=de_at
cab speng :setlocal spell spelllang=en_us
cab spoff :setlocal spell& spelllang&
cab Q :q!
nnoremap <leader>T :ToggleTerm<CR>
" nnoremap <leader>T :ToggleTerm direction=tab<CR>
nnoremap <leader><C-T> :ToggleTermSendCurrentLine<CR>
vnoremap <leader>T :ToggleTermSendVisualSelection<CR>
nnoremap <S-F6> :TermExec cmd="python3 %"<CR>
set wrap
augroup RestoresursorShapeOnExit
    autocmd!
    autocmd VimLeave * set guicursor=a:hor20,a:blinkon1,
augroup END


    
set guicursor=c-ci-cr:hor20,n-o-r-v-sm:block,i-ve:ver10,n-i-ve:blinkon1,
set cursorline
set cursorlineopt=number
set title
let &titlestring="nv: %F"
" function LfIfStdinEmpty()
"     if argc() == 0
"         lua require ("lf").start()
"     endif
" endfunction

" au VimEnter * call LfIfStdinEmpty()

source ~/.config/nvim/vim/markdown.vim
