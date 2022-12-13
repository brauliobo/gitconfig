function! myspacevim#before() abort
  " checkers: prevent ruby-lint
  autocmd VimEnter * NeomakeDisable

  " fill column display
  set cc=100

  "set <leader> key
  let g:mapleader=","

  "key mapping for window navigation
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l

  " start with first character on newline
  nmap 0 ^

  "Activate smartcase
  set ic
  set smartcase

  " rename current file
  map <leader>n :call RenameFile()<cr>

  "" FIND
  nmap <Leader>t :Telescope find_files<cr>
  " grep command
  set grepprg=ag

  "save shortcut
  nnoremap <leader>w :wa<CR>

  "" PRY
  " …also, Insert Mode as bpry<space>
  iabbr bpry require'pry';binding.pry
  " And admit that the typos happen:
  iabbr bpry require'pry';binding.pry
  " Add the pry debug line with \bp (or <Space>bp, if you did: map <Space> <Leader> )
  map <Leader>bp orequire'pry';binding.pry<esc>:w<cr>
  " Alias for one-handed operation:
  map <Leader><Leader>p <Leader>bp

  ""Select between conflict blocks
  "select ours
  nmap <leader>so \<<<<<<<<CR>dd\=======<CR>V/>>>>>>><CR>d
  "select theirs
  nmap <leader>st \<<<<<<<<CR>V/=======<CR>d\>>>>>>><CR>dd
  "select both
  nmap <leader>sb \<<<<<<<<CR>dd\=======<CR>dd\>>>>>>><CR>dd
  "find next conflict
  nmap <leader>fc /<<<<<<<<CR>

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

function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction
