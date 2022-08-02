function! myspacevim#before() abort
  " checkers: prevent ruby-lint
  autocmd VimEnter * NeomakeDisable

  " grep command
  set grepprg=ag

  " fill column display
  set cc=100

  "set <leader> key
  let g:mapleader=","

  "key mapping for window navigation
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l

  " …also, Insert Mode as bpry<space>
  iabbr bpry require'pry';binding.pry
  " And admit that the typos happen:
  iabbr bpry require'pry';binding.pry
  " Add the pry debug line with \bp (or <Space>bp, if you did: map <Space> <Leader> )
  map <Leader>bp orequire'pry';binding.pry<esc>:w<cr>
  " Alias for one-handed operation:
  map <Leader><Leader>p <Leader>bp

  " start with first character on newline
  nmap 0 ^

  "replace camelcase and underscore word navigation
  "map <silent> w <Plug>CamelCaseMotion_w
  "map <silent> b <Plug>CamelCaseMotion_b
  "map <silent> e <Plug>CamelCaseMotion_e
  "sunmap w
  "sunmap b
  "sunmap e
  "omap <silent> iw <Plug>CamelCaseMotion_iw
  "xmap <silent> iw <Plug>CamelCaseMotion_iw
  "omap <silent> ib <Plug>CamelCaseMotion_ib
  "xmap <silent> ib <Plug>CamelCaseMotion_ib
  "omap <silent> ie <Plug>CamelCaseMotion_ie
  "xmap <silent> ie <Plug>CamelCaseMotion_ie
endfunction

function! myspacevim#after() abort
endfunction
