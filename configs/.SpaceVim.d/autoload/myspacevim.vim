function! myspacevim#before() abort
  " fill column display
  set cc=100

  "key mapping for window navigation
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l

  "set <leader> key
  let g:mapleader=","

  " checkers: prevent ruby-lint
  autocmd VimEnter * NeomakeDisable

  " start with first character on newline
  nmap 0 ^

  " grep command
  set grepprg=ag
endfunction

function! myspacevim#after() abort
endfunction
