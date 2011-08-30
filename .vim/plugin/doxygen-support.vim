"===================================================================================
"
"         FILE:  doxygen-support.vim
"
"  DESCRIPTION:  Build a menu for inserting user defined doxygen templates.
"
"       AUTHOR:  Dr.-Ing. Fritz Mehner
"        EMAIL:  mehner@fh-swf.de
"      COMPANY:  Fachhochschule Südwestfalen, Iserlohn
"      VERSION:  see variable  g:DoxygenVersion  below
"      CREATED:  07.07.2007
"     REVISION:  $Id: doxygen-support.vim,v 1.16 2008/03/22 12:13:05 mehner Exp $
"      LICENSE:  Copyright (c) 2007-2008, Fritz Mehner
"                This program is free software; you can redistribute it and/or
"                modify it under the terms of the GNU General Public License as
"                published by the Free Software Foundation, version 2 of the
"                License.
"                This program is distributed in the hope that it will be
"                useful, but WITHOUT ANY WARRANTY; without even the implied
"                warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                PURPOSE.
"                See the GNU General Public License version 2 for more details.
"
"===================================================================================
"
if v:version < 700
  echohl WarningMsg | echo 'plugin doxygen-support.vim needs Vim version >= 7'| echohl None
  finish
endif
"
" Prevent duplicate loading:
"
if exists("g:DoxygenVersion") || &cp
 finish
endif
"
let g:DoxygenVersion= "2.0.2"               " version number of this script; do not change
"
"------------------------------------------------------------------------------
" Platform specific items
"------------------------------------------------------------------------------
let s:MSWIN =   has("win16") || has("win32") || has("win64") || has("win95")
" 
if  s:MSWIN
	let s:installation						= 'system'
	let s:plugin_dir							= $VIM.'\vimfiles\'
	let s:Doxy_GlobalTemplateFile	= s:plugin_dir.'doxygen-support/templates/doxygen.templates'
	let s:Doxy_GlobalTemplateDir	= fnamemodify( s:Doxy_GlobalTemplateFile, ":p:h" ).'/'
	let s:Doxy_LocalTemplateFile	= s:Doxy_GlobalTemplateFile
	let s:Doxy_LocalTemplateDir 	= s:Doxy_GlobalTemplateDir
else
  let s:plugin_dir  	= $HOME.'/.vim/'
	"
	" user / system wide installation (Linux/Unix)
	"
	if match( expand("<sfile>"), $VIM ) >= 0
		"
		" system wide installation 
		"
		let s:installation						= 'system'
		let s:plugin_dir  						= $VIM.'/vimfiles/'
		let s:Doxy_GlobalTemplateFile	= s:plugin_dir.'doxygen-support/templates/doxygen.templates'
		let s:Doxy_GlobalTemplateDir	= fnamemodify( s:Doxy_GlobalTemplateFile, ":p:h" ).'/'
		let s:Doxy_LocalTemplateFile	= $HOME.'/.vim/doxygen-support/templates/doxygen.templates'
		let s:Doxy_LocalTemplateDir 	= fnamemodify( s:Doxy_LocalTemplateFile, ":p:h" ).'/'
	else
		"
		" user installation assumed
		"
		let s:installation							= 'local'
		let s:plugin_dir  							= $HOME.'/.vim/'
		let s:Doxy_GlobalTemplateFile   = ''
		let s:Doxy_GlobalTemplateDir    = ''
		let s:Doxy_LocalTemplateFile    = s:plugin_dir.'doxygen-support/templates/doxygen.templates'
		let s:Doxy_LocalTemplateDir     = fnamemodify( s:Doxy_LocalTemplateFile, ":p:h" ).'/'
	endif
endif
"
"------------------------------------------------------------------------------
"  Control variables (user configurable)
"------------------------------------------------------------------------------
let s:Doxy_ExCommandLeader   = 'Doxy'           " Ex command leader
let s:Doxy_LoadMenus         = 'yes'            " toggle default
let s:Doxy_RootMenu          = 'Do&xy.'         " name of the root menu (not empty)

"
"------------------------------------------------------------------------------
"  Control variables (not user configurable)
"------------------------------------------------------------------------------
let s:TemplateModes              =	{	
											\								'above' : '',
											\								'append': '',
											\								'below' : 'split',
											\								'insert': 'split', 
											\								'start' : '', 
											\							}
let s:Doxy_TemplateMode          = {}

let s:Doxy_ExpansionLimit        = 10
let s:Doxy_FileVisited           = []
let s:Doxy_ItemOrder             = []
"
let s:Doxy_MacroNameRegex        = '\([a-zA-Z][a-zA-Z0-9_]*\)'
let s:Doxy_MacroLineRegex				 = '^\s*\$'.s:Doxy_MacroNameRegex.'\$\s*=\s*\(.*\)'
let s:Doxy_ExpansionRegex				 = '\$?'.s:Doxy_MacroNameRegex.'\(:\a\)\?\$'
let s:Doxy_NonExpansionRegex		 = '\$'.s:Doxy_MacroNameRegex.'\(:\a\)\?\$'
"
let s:Doxy_TemplateNameDelimiter = '-+_, '

"
" == <menu name> == [ <template mode> == [ <menu mode> ] ]
"
let s:Doxy_TemplateNameRegex		 = '\([a-zA-Z][0-9a-zA-Z'.s:Doxy_TemplateNameDelimiter.']\+\)'
let s:Doxy_TemplateLineRegex		 = '^==\s*'.s:Doxy_TemplateNameRegex.'\(\.'.s:Doxy_TemplateNameRegex.'\)*\s*==\s*'
let s:Doxy_TemplateLineRegex		.= '\([a-z]\+\s*==\s*\)\?'

let s:Doxy_TemplateSaveCmd       = {}
let s:Doxy_TemplateSaveMenu      = {}
"
let s:Doxy_ExpansionCounter    = {}
let s:Doxy_Template            = {}
let s:Doxy_Macro               = {'$sortmenus$'      : 'no',
											\						'$AUTHOR$'         : 'first name surname', 
											\						'$AUTHORREF$'      : '',
											\						'$EMAIL$'          : '',
											\						'$COMPANY$'        : '',
											\						'$PROJECT$'        : '',
											\						'$COPYRIGHTHOLDER$': '' 
											\						}
let	s:Doxy_MacroFlag						= {	':l' : 'lowercase'			, 
											\							':u' : 'uppercase'			, 
											\							':c' : 'capitalize'		, 
											\							':L' : 'legalize name'	, 
											\						}
"
let s:Doxy_TemplateOverwrittenMsg= 'no'
"
let s:Doxy_FormatDate						= '%x'
let s:Doxy_FormatTime						= '%X'
let s:Doxy_FormatYear						= '%Y'
"
"------------------------------------------------------------------------------
"  Look for global variables (if any), to override the defaults.
"------------------------------------------------------------------------------
function! s:DoxygenCheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction
"
call s:DoxygenCheckGlobal('Doxy_ExCommandLeader       ')
call s:DoxygenCheckGlobal('Doxy_FormatDate            ')
call s:DoxygenCheckGlobal('Doxy_FormatTime            ')
call s:DoxygenCheckGlobal('Doxy_FormatYear            ')
call s:DoxygenCheckGlobal('Doxy_GlobalTemplateDir     ')
call s:DoxygenCheckGlobal('Doxy_GlobalTemplateFile    ')
call s:DoxygenCheckGlobal('Doxy_LoadMenus             ')
call s:DoxygenCheckGlobal('Doxy_LocalTemplateDir      ')
call s:DoxygenCheckGlobal('Doxy_LocalTemplateFile     ')
call s:DoxygenCheckGlobal('Doxy_RootMenu              ')
call s:DoxygenCheckGlobal('Doxy_TemplateOverwrittenMsg')
"
if s:Doxy_RootMenu == ""
  let s:Doxy_RootMenu = 'Do&xy.'       " use the default
endif
let	s:Doxy_RootMenuClean     = substitute( s:Doxy_RootMenu, '&', '', 'g' )[0:-2]
"
"------------------------------------------------------------------------------
" find the Ex command leader
" remove non-word character, leading digits, underscore
" first character must be uppercase
"------------------------------------------------------------------------------
"
let s:Doxy_ExCommandLeader  = substitute( s:Doxy_ExCommandLeader, '\(^\d\+\|\W\|_\)', '', 'g' )
let s:Doxy_ExCommandLeader  = substitute( s:Doxy_ExCommandLeader, "^\\(.\\)", "\\U\\0", "" )
if s:Doxy_ExCommandLeader == ""
  let s:Doxy_RootMenu = s:Doxy_RootMenuClean
endif
"
"------------------------------------------------------------------------------
" find the menu header (last part of the complete root menu name)
"------------------------------------------------------------------------------
"
let s:Doxy_Menuheader = matchstr( s:Doxy_RootMenu, '[^\.]\+\.$' )
let s:Doxy_Menuheader = substitute( s:Doxy_Menuheader, '\.\+$', '', '' )
if s:Doxy_Menuheader == ""
  let s:Doxy_RootMenu = s:Doxy_RootMenuClean
endif
let	s:Doxy_Menutitle	= {}

"===================================================================================
" FUNCTIONS
"===================================================================================

"------------------------------------------------------------------------------
"  DoxygenToolMenuLoad
"  set the tool menu item (Load Menu)
"------------------------------------------------------------------------------
function! DoxygenToolMenuLoad ( action )
	if a:action == 'set'
		amenu   <silent> 40.1000 &Tools.-SEP0- :
		amenu   <silent> 40.1035 &Tools.Load\ Doxygen\ Menu <C-C>:call DoxygenCreateGuiMenus()<CR>
	end
	if a:action == 'remove'
		aunmenu <silent> &Tools.Load\ Doxygen\ Menu
	end
endfunction    " ----------  end of function DoxygenToolMenuLoad  ----------

"------------------------------------------------------------------------------
"  DoxygenToolMenuUnload
"  set the tool menu item (Load Menu)
"------------------------------------------------------------------------------
function! DoxygenToolMenuUnload ( action )
	if a:action == 'set'
		amenu   <silent> 40.1000 &Tools.-SEP0- :
		amenu   <silent> 40.1035 &Tools.Unload\ Doxygen\ Menu <C-C>:call DoxygenRemoveGuiMenus()<CR>
	end
	if a:action == 'remove' 
    aunmenu <silent> &Tools.Unload\ Doxygen\ Menu
	end
endfunction    " ----------  end of function DoxygenToolMenuUnload  ----------

"------------------------------------------------------------------------------
"  DoxygenCreateGuiMenus
"  create  the doxygen menu / change tool menu
"------------------------------------------------------------------------------
let s:Doxy_MenuVisible = 0								" state variable controlling the menus

function! DoxygenCreateGuiMenus ()
  if s:Doxy_MenuVisible == 0
    call DoxygenInitMenu()								" sets s:Doxy_MenuVisible = 1
    call DoxygenToolMenuLoad('remove')
		call DoxygenToolMenuUnload('set')
  endif
endfunction    " ----------  end of function DoxygenCreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  DoxygenRemoveGuiMenus
"  remove the doxygen menu / change tool menu
"------------------------------------------------------------------------------
function! DoxygenRemoveGuiMenus ()
  if s:Doxy_MenuVisible == 1
    "
    exe "aunmenu <silent> ".s:Doxy_RootMenu
		call DoxygenToolMenuUnload('remove')
    call DoxygenToolMenuLoad('set')
    "
    let s:Doxy_MenuVisible = 0
  endif
endfunction    " ----------  end of function DoxygenRemoveGuiMenus  ----------

"------------------------------------------------------------------------------
"  DoxygenInitMenu
"  create the doxygen menu items
"------------------------------------------------------------------------------
function! DoxygenInitMenu ()
  "
  silent exe "amenu .1 ".s:Doxy_RootMenu.s:Doxy_Menuheader.'\ \ (rebuild)    <Esc><Esc>:call DoxygenRebuild( "yes" )<CR>'
  silent exe "amenu .1 ".s:Doxy_RootMenu.'-Sep00-    :'

  "------------------------------------------------------------------------------
  "  remove existing menus (if any)
  "------------------------------------------------------------------------------
	let submenu_removed	= {}
  if s:Doxy_MenuVisible == 1
    for key in keys(s:Doxy_TemplateSaveMenu)
			let	submenu_path	= matchstr( key, '^'.s:Doxy_TemplateNameRegex.'\.' )[0:-2]
			if submenu_path != ''
				if !has_key( submenu_removed, submenu_path )
					let	submenu_removed[submenu_path]	= submenu_path
					" remove a complete submenu
					exe "silent aunmenu ".s:Doxy_RootMenu.submenu_path
				end
			else
				exe "silent aunmenu ".s:Doxy_RootMenu.key
			end
    endfor
  end

  "------------------------------------------------------------------------------
  "  build new menus from the templates / save the templates
  "------------------------------------------------------------------------------
  if s:Doxy_Macro['$sortmenus$'] == 'yes'
		let keylist	= sort( keys(s:Doxy_Template ))
	else
		let keylist	= s:Doxy_ItemOrder
	endif

	let	sepnumber		= 1

	for key in keylist
		"
		" build submenu header
		"
		let	submenu_path	= matchstr( key, '\('.s:Doxy_TemplateNameRegex.'\.\)\+' )
		if submenu_path != ''
			if submenu_path != '' && !has_key( s:Doxy_Menutitle, submenu_path )
				let s:Doxy_Menutitle[submenu_path]	= submenu_path
				let	submenu_name	= split( submenu_path, '\.' )[-1]
				exe  "amenu  <silent> .100 ".s:Doxy_RootMenu.submenu_path.submenu_name."<Tab>".s:Doxy_RootMenuClean."       <Esc>"
				exe  "amenu  <silent> .100 ".s:Doxy_RootMenu.submenu_path."-SEP".sepnumber."-       <Esc>"
				let	sepnumber	= sepnumber+1
				let s:Doxy_Template[ submenu_path.submenu_name."<Tab>".s:Doxy_RootMenuClean ] = ''
			end
		end
		"
		" build a normal mode menu entry
		"
		exe "amenu  <silent> .100 ".s:Doxy_RootMenu.key."  <Esc><Esc>:call DoxygenInsertTemplate ('".key."', 'a' )<CR>"
		"
		" build a visual mode menu entry
		"
		if match( s:Doxy_Template[key], '<SPLIT>' )
			exe "vmenu  <silent> .100 ".s:Doxy_RootMenu.key."  <Esc><Esc>:call DoxygenInsertTemplate ('".key."', 'v' )<CR>"
		end

	endfor

  let s:Doxy_TemplateSaveMenu = s:Doxy_Template

  let s:Doxy_MenuVisible = 1
  return
endfunction    " ----------  end of function DoxygenInitMenu  ----------

"------------------------------------------------------------------------------
"  DoxygenRebuild
"  rebuild commands and the menu from the (changed) template file
"------------------------------------------------------------------------------
function! DoxygenRebuild ( msg )
  "-------------------------------------------------------------------------------
  "   (1.1) template file already loaded:
  "     (1.1.1) window open : go to this window
  "     (1.1.2) window not open : open a window for the template file
  "     update the template file
  "     reread the template file
  "     rebuild commands and menus
  "   (1.2) 
  "     update the current buffer
  "     open the template file in a new window for editing
  "-------------------------------------------------------------------------------
	let s:Doxy_ItemOrder    = []
	let s:Doxy_Template     = {}
	let s:Doxy_FileVisited  = []
	let	s:Doxy_Menutitle		= {}

	if s:installation == 'system' && filereadable( s:Doxy_GlobalTemplateFile )
		call DoxygenReadTemplates( s:Doxy_GlobalTemplateFile ) 
		if a:msg == 'yes'
			echomsg "doxygen comments rebuilt from global file '".s:Doxy_GlobalTemplateFile."'"
		end
	endif

	if filereadable( s:Doxy_LocalTemplateFile )
		call DoxygenReadTemplates( s:Doxy_LocalTemplateFile )
		if a:msg == 'yes'
			echomsg "doxygen comments rebuilt from local file '".s:Doxy_LocalTemplateFile."'"
		endif
	endif

	call DoxygenBuildCommands()

endfunction    " ----------  end of function DoxygenRebuild  ----------

"------------------------------------------------------------------------------
"  DoxygenReadTemplates
"  read the template file(s), build the macro and the template dictionary
"
"------------------------------------------------------------------------------
function! DoxygenReadTemplates ( templatefile )

  if !filereadable( a:templatefile )
    echohl WarningMsg
    echomsg "doxygen template file '".a:templatefile."' does not exist or is not readable"
    echohl None
    return
  endif

	let	skipmacros	= 0
  let s:Doxy_FileVisited  += [a:templatefile]

  "------------------------------------------------------------------------------
  "  read template file, start with an empty template dictionary
  "------------------------------------------------------------------------------

  let item  = ''
  for line in readfile( a:templatefile )
		" if not a comment :
    if line !~ '^#'
      "
      " macros and file includes
      "
      let string  = matchlist( line, s:Doxy_MacroLineRegex )
      if !empty(string) && skipmacros == 0
        let key = '$'.string[1].'$'
        let val = string[2]
        let val = substitute( val, '\s\+$', '', '' )
        let val = substitute( val, "[\"\']$", '', '' )
        let val = substitute( val, "^[\"\']", '', '' )
        "
        if key == '$includefile$' && count( s:Doxy_FileVisited, val ) == 0
					let path   = fnamemodify( a:templatefile, ":p:h" )
          call DoxygenReadTemplates( path.'/'.val )    " recursive call
        else
          let s:Doxy_Macro[key] = val
        endif
        continue                                            " next line
      endif
      "
      " template header
      "
      let name  = matchstr( line, s:Doxy_TemplateLineRegex )
      "
      if name != ''
        let part  = split( name, '\s*==\s*')
        let item  = part[0]
        if has_key( s:Doxy_Template, item ) && s:Doxy_TemplateOverwrittenMsg == 'yes'
          echomsg "existing doxygen template '".item."' overwritten"
        endif
        let s:Doxy_ItemOrder += [ item ]
        let s:Doxy_Template[item] = ''
				let skipmacros	= 1
        "
        let s:Doxy_TemplateMode[item] = 'below'
				if has_key( s:TemplateModes, get( part, 1, 'NONE' ) )
					let s:Doxy_TemplateMode[item] = part[1]
				endif
				"
      else
				"
				" template body
				"
        if item != ''
					" Convert \# to #  (preprocessor statements)
					let line = substitute( line, '\\#', '#','' ) 
					"
          let s:Doxy_Template[item] = s:Doxy_Template[item].line."\n"
        endif
      endif
    endif
  endfor

endfunction    " ----------  end of function DoxygenReadTemplates  ----------

"------------------------------------------------------------------------------
"  DoxygenBuildCommands
"  build the commands from the template dictionary
"------------------------------------------------------------------------------
function! DoxygenBuildCommands ()

  "-------------------------------------------------------------------------------
  "   remove existing commands
  "-------------------------------------------------------------------------------
  if s:Doxy_TemplateSaveCmd != {}
    for key in keys(s:Doxy_TemplateSaveCmd)
      exe "silent delcommand  ".s:Doxy_ExCommandLeader.key
    endfor
    let s:Doxy_TemplateSaveCmd = {}
  end

  "-------------------------------------------------------------------------------
  "   build new commands; report no error if a command already exists
  "-------------------------------------------------------------------------------
  for key in sort( keys(s:Doxy_Template) )
    let camelcase = s:DoxygenCamelCaseName( key )
    let s:Doxy_TemplateSaveCmd[camelcase] = camelcase
    exe "command!   ".s:Doxy_ExCommandLeader.camelcase."  call DoxygenInsertTemplate ('".key."', 'a' )"
  endfor

endfunction    " ----------  end of function DoxygenBuildCommands  ----------

"------------------------------------------------------------------------------
"  s:DoxygenCamelCaseName
"  Build a camel-case-name from a raw name by removing separators and joining
"  the parts each starting with an uppercase letter.
"------------------------------------------------------------------------------
function! s:DoxygenCamelCaseName ( raw_name )
	let noamper	= substitute( a:raw_name, '&', '', 'g' )
  let parts = split( noamper, '['.s:Doxy_TemplateNameDelimiter.'\.]' )
  let parts = map( parts, 'substitute( v:val, "^\\(.\\)", "\\U\\0", "" )' )
  return join( parts, '' )
endfunction    " ----------  end of function s:DoxygenCamelCaseName  ----------

"------------------------------------------------------------------------------
"  DoxygenInsertTemplate
"  insert a template from the template dictionary
"  do macro expansion
"------------------------------------------------------------------------------
function! DoxygenInsertTemplate ( key, mode )

	if !has_key( s:Doxy_Template, a:key )
		echomsg "Template '".a:key."' not found. Please check your template file in '".s:Doxy_GlobalTemplateDir."'"
		return
	endif
	let	pos1	= ''
	let	pos2	= ''

  "------------------------------------------------------------------------------
  "  insert the user macros
  "------------------------------------------------------------------------------

	" use internal formatting to avoid conficts when using == below
	"
	let	equalprg_save	= &equalprg
	set equalprg= 

  let templatemode  = s:Doxy_TemplateMode[a:key]

	" remove <SPLIT> and insert the complete macro
	"
	if a:mode == 'a'
		let val = DoxygenExpandUserMacros (a:key)
		if val	== ""
			return
		endif
		let val	= DoxygenExpandSingleMacro( val, '<SPLIT>', '' )
		"
		" insert below current line
		"
		if templatemode == 'below'
			let pos1  = line(".")+1
			put  =val
			let pos2  = line(".")
			" proper indenting 
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
		endif

		"
		" insert above current line
		"
		if templatemode == 'above'
			let pos1  = line(".")
			put! =val
			let pos2  = line(".")
			" proper indenting 
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
		endif
		"
		" new top of the file
		"
		if templatemode == 'start'
			normal gg
			let pos1  = 1
			put! =val
			let pos2  = line(".")
			" proper indenting 
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
		endif
		"
		" append to the current line
		"
		if templatemode == 'append'
			let pos1  = line(".")
			put =val
			let pos2  = line(".")-1
			exe ":".pos1
			:join!
		endif
		"
		" insert after cursor position (normal mode)
		" insert at cursor position (insert mode)
		"
		if templatemode == 'insert'
			let val   = substitute( val, '\n$', '', '' )
			let pos1  = line(".")
			let pos2  = pos1 + count( split(val,'\zs'), "\n" ) 
			" assign to the unnamed register "" :
			let @"=val
			normal p
			" reformat only multiline inserts
			if pos2-pos1 > 0
				exe ":".pos1
				let ins	= pos2-pos1+1
				exe "normal ".ins."=="
			end
		endif
		"
	endif
	"
	" =====  visual mode  ===============================
	"
	if  a:mode == 'v'
		let val = DoxygenExpandUserMacros (a:key)
		if val	== ""
			return
		endif

		let part	= split( val, '<SPLIT>' )
		if len(part) < 2
			let part	= [ "" ] + part
			echomsg 'SPLIT missing in template '.a:key
		endif
		"
		" 'visual' and mode 'insert': 
		"   <part0><marked area><part1>
		" part0 and part1 can consist of several lines
		"
		if templatemode == 'insert'
			let pos1  = line(".")
			let pos2  = pos1
			let	string= @*
			let replacement	= part[0].string.part[1]
			" remove trailing '\n'
			let replacement   = substitute( replacement, '\n$', '', '' )
			exe ':s/'.string.'/'.replacement.'/'
		endif
		"
		" 'visual' and mode 'below': 
		"   <part0>
		"   <marked area>
		"   <part1>
		" part0 and part1 can consist of several lines
		"
		if templatemode == 'below'

			:'<put! =part[0]
			:'>put  =part[1]

			let pos1  = line("'<") - len(split(part[0], '\n' ))
			let pos2  = line("'>") + len(split(part[1], '\n' ))
			""			echo part[0] part[1] pos1 pos2
			"			" proper indenting 
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
		endif
		"
	endif

	" restore formatter programm
	let &equalprg	= equalprg_save

  "------------------------------------------------------------------------------
  "  position the cursor
  "------------------------------------------------------------------------------
	if pos1 != ''
		exe ":".pos1
		let mtch = search( '<CURSOR>', "c", pos2 )
		if mtch != 0
			if  matchend( getline(mtch) ,'<CURSOR>') == match( getline(mtch) ,"$" )
				normal 8x
				:startinsert!
			else
				normal 8x
				:startinsert
			endif
		else
			" to the end of the block; needed for repeated inserts
			if templatemode == 'below'
				exe ":".pos2
			endif
		endif
	endif

endfunction    " ----------  end of function DoxygenInsertTemplate  ----------

"------------------------------------------------------------------------------
"  DoxygenExpandUserMacros
"------------------------------------------------------------------------------
function! DoxygenExpandUserMacros ( key )

  let template 								= s:Doxy_Template[ a:key ]
	let	s:Doxy_ExpansionCounter	= {}										" reset the expansion counter

  "------------------------------------------------------------------------------
  "  renew the predefined macros and expand them
	"  can be replaced, with e.g. $?DATE$
  "------------------------------------------------------------------------------
	let	s:Doxy_Macro['$BASENAME$']	= toupper(expand("%:t:r"))
  let s:Doxy_Macro['$DATE$']  		= DoxygenInsertDateAndTime('d')
  let s:Doxy_Macro['$FILE$'] 			= expand("%:t")
  let s:Doxy_Macro['$PATH$']  		= expand("%:p:h")
  let s:Doxy_Macro['$SUFFIX$'] 		= expand("%:e")
  let s:Doxy_Macro['$TIME$']  		= DoxygenInsertDateAndTime('t')
  let s:Doxy_Macro['$YEAR$']  		= DoxygenInsertDateAndTime('y')

  "------------------------------------------------------------------------------
  "  look for replacements
  "------------------------------------------------------------------------------
	while match( template, s:Doxy_ExpansionRegex ) != -1
		let macro				= matchstr( template, s:Doxy_ExpansionRegex )
		let replacement	= substitute( macro, '?', '', '' )
		let template		= substitute( template, escape( macro, '$' ), replacement, "g" )

		let match	= matchlist( macro, s:Doxy_ExpansionRegex )

		if match[1] != ''
			let macroname	= '$'.match[1].'$'
			"
			" notify flag action, if any
			let flagaction	= ''
			if has_key( s:Doxy_MacroFlag, match[2] )
				let flagaction	= ' (-> '.s:Doxy_MacroFlag[ match[2] ].')'
			endif
			"
			" ask for a replacement
			if has_key( s:Doxy_Macro, macroname )
				let	name	= DoxygenInput( match[1].flagaction.' : ', DoxygenApplyFlag( s:Doxy_Macro[macroname], match[2] ) )
			else
				let	name	= DoxygenInput( match[1].flagaction.' : ', '' )
			endif
			if name == ""
				return ""
			endif
			"
			" keep the modified name
			let s:Doxy_Macro[macroname]  			= DoxygenApplyFlag( name, match[2] )
		endif
	endwhile

  "------------------------------------------------------------------------------
  "  do the actual macro expansion
	"  loop over the macros found in the template
  "------------------------------------------------------------------------------
	while match( template, s:Doxy_NonExpansionRegex ) != -1

		let macro			= matchstr( template, s:Doxy_NonExpansionRegex )
		let match			= matchlist( macro, s:Doxy_NonExpansionRegex )

		if match[1] != ''
			let macroname	= '$'.match[1].'$'


			if has_key( s:Doxy_Macro, macroname ) 
				"-------------------------------------------------------------------------------
				"   check for recursion
				"-------------------------------------------------------------------------------
				if has_key( s:Doxy_ExpansionCounter, macroname )
					let	s:Doxy_ExpansionCounter[macroname]	+= 1
				else
					let	s:Doxy_ExpansionCounter[macroname]	= 0
				endif
				if s:Doxy_ExpansionCounter[macroname]	>= s:Doxy_ExpansionLimit
					echomsg " recursion terminated for recursive macro ".macroname
					return template
				endif
				"-------------------------------------------------------------------------------
				"   replace
				"-------------------------------------------------------------------------------
				let replacement = DoxygenApplyFlag( s:Doxy_Macro[macroname], match[2] )
				let template 		= substitute( template, escape( macro, '$' ), replacement, "g" )
			else
				"
				" macro not yet defined
				let s:Doxy_Macro['$'.match[1].'$']  		= ''
			endif
		endif

	endwhile

  return template
endfunction    " ----------  end of function DoxygenExpandUserMacros  ----------
"
"------------------------------------------------------------------------------
"  DoxygenApplyFlag
"------------------------------------------------------------------------------
function! DoxygenApplyFlag ( val, flag )
	"
	" l : lowercase
	if a:flag == ':l'
		return  tolower(a:val)
	end
	"
	" u : uppercase
	if a:flag == ':u'
		return  toupper(a:val)
	end
	"
	" c : capitalize
	if a:flag == ':c'
		return  toupper(a:val[0]).a:val[1:]
	end
	"
	" L : legalized name
	if a:flag == ':L'
		return  DoxygenLegalizeName(a:val)
	end
	"
	" flag not valid
	return a:val			
endfunction    " ----------  end of function DoxygenApplyFlag  ----------
"
"------------------------------------------------------------------------------
"  DoxygenExpandSingleMacro
"------------------------------------------------------------------------------
function! DoxygenExpandSingleMacro ( val, macroname, replacement )
  return substitute( a:val, escape(a:macroname, '$' ), a:replacement, "g" )
endfunction    " ----------  end of function DoxygenExpandSingleMacro  ----------

"------------------------------------------------------------------------------
"  DoxygenInsertDateAndTime
"------------------------------------------------------------------------------
function! DoxygenInsertDateAndTime ( format )
	if a:format == 'd'
		return strftime( s:Doxy_FormatDate )
	end
	if a:format == 't'
		return strftime( s:Doxy_FormatTime )
	end
	if a:format == 'dt'
		return strftime( s:Doxy_FormatDate ).' '.strftime( s:Doxy_FormatTime )
	end
	if a:format == 'y'
		return strftime( s:Doxy_FormatYear )
	end
endfunction    " ----------  end of function DoxygenInsertDateAndTime  ----------
"
"-------------------------------------------------------------------------------
"   DoxygenLegalizeName : replace non-word characters by underscores
"   - multiple whitespaces
"   - multiple non-word characters
"   - multiple underscores
"-------------------------------------------------------------------------------
function! DoxygenLegalizeName ( name )
	let identifier = substitute(     a:name, '\s\+',  '_', 'g' )
	let identifier = substitute( identifier, '\W\+',  '_', 'g' ) 
	let identifier = substitute( identifier, '_\+', '_', 'g' )
	return identifier
endfunction    " ----------  end of function DoxygenLegalizeName  ----------
"
"------------------------------------------------------------------------------
"  DoxygenInput: Input after a highlighted prompt
"------------------------------------------------------------------------------
function! DoxygenInput ( promp, text )
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	let	retval=input( a:promp, a:text )										" read input
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	return retval
endfunction    " ----------  end of function DoxygenInput ----------

"------------------------------------------------------------------------------
"  INITIALIZE THIS PLUGIN
"  build the commands
"  build the menus (GUI only)
"------------------------------------------------------------------------------
"
call DoxygenRebuild( 'no' )

if has("gui_running")
	"
	if s:Doxy_LoadMenus == 'yes'
		call DoxygenToolMenuLoad('set')
		call DoxygenCreateGuiMenus()
	else
		call DoxygenToolMenuLoad('set')
	endif

endif
"
command! Doxygen   call DoxygenRebuild( 'yes' )
"
"------------------------------------------------------------------------------
"vim: set tabstop=2 shiftwidth=2:
