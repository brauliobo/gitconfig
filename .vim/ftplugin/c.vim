set cinoptions=:0,l1,g0,(0,W2s
set textwidth=120

function! DevhelpOrManpage()
	let word = expand("<cword>")
	if word =~ '^gtk_' || word =~ '^g_' || word =~ '^Gtk' || word =~ '^GTK'
		exec ":silent !devhelp -s " . word . " &"
		redraw!
	else
		exec ":Man " . word
	endif
endfunction

nmap <S-K> :call DevhelpOrManpage()<CR>
nmap <F5> :make -C <C-R>=expand("%:p:h")<CR> install<CR>
nmap <S-F5> :make -C <C-R>=expand("%:p:h")<CR> clean<CR>
