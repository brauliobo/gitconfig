" ============================================================================
"         File: project-vimrc.vim
"  Description: Loads a custom vimrc by project for your project!
"   Maintainer: Ian Liu Rodrigues (ian.liu88 at gmail dot com)
" Last Changed: Wednesday, 3 February 2010
"      License: This program is free software. It comes without any warranty,
"               to the extent permitted by applicable law. You can redistribute
"               it and/or modify it under the terms of the Do What The Fuck You
"               Want To Public License, Version 2, as published by Sam Hocevar.
"               See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" ============================================================================

if exists("g:ProjectVimrc_Version")
	finish
endif

let g:ProjectVimrcVersion = "0.1.0"

let s:project_dir = ''

if !exists("g:ProjectVimrc_SearchName")
	let g:ProjectVimrc_SearchName = "project.vimrc"
endif

if !exists("g:ProjectVimrc_Heaven")
	let g:ProjectVimrc_Heaven = "/home"
endif

if !exists("g:ProjectVimrc_AutoSource")
	let g:ProjectVimrc_AutoSource = 1
endif

if g:ProjectVimrc_AutoSource
	autocmd VimEnter * call ProjectVimrc_Source()
endif

function ProjectVimrc_Source()
	let project_vimrc = findfile(g:ProjectVimrc_SearchName, '.;' . g:ProjectVimrc_Heaven)
	if strlen(project_vimrc) != 0
		let s:project_dir = fnamemodify(project_vimrc, ":p:h")
		exec "source " . project_vimrc
	endif
endfunction

function ProjectVimrc_GetProjectDir()
	return s:project_dir
endfunction
