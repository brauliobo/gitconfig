
"
" My python options
"

set shiftwidth=4
set tabstop=4
set expandtab
set smarttab
set completeopt-=menu
set completeopt+=menuone

" Run current python module on <F5>
nmap <F5> :!python "%"<CR>

" Omnicomplete ;)
inoremap <expr> . PythonCompleteDot()

function! PythonCompleteDot()
    return '.' . "\<C-X>\<C-O>\<C-P>\<C-R>=pumvisible() ? \"\\<down>\" : \"\"\<cr>"
endfunction
