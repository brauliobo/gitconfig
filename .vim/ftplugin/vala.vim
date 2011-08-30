set tabstop=4
set shiftwidth=4
set errorformat=%f:%1.%c-%[%^:]%#:\ %t%[%^:]%#:\ %m

nmap <F5> :!valac %
nmap <F6> :!./<C-R>:expand("%:t:r")
