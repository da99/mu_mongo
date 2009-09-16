let SessionLoad = 1
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
inoremap <C-Space> 
map! <S-Insert> <MiddleMouse>
noremap s :TCommentAs =&ft_
noremap n :TCommentAs =&ft 
noremap a :TCommentAs 
noremap b :TCommentBlock
vnoremap <silent> r :TCommentRight
vnoremap <silent> i :TCommentInline
nnoremap <silent> r :TCommentRight
onoremap <silent> r :TCommentRight
noremap   :TComment 
noremap <silent> p m`vip:TComment``
vnoremap <silent>  :TCommentMaybeInline
nnoremap <silent>  :TComment
onoremap <silent>  :TComment
vmap [% [%m'gv``
noremap \_s :TCommentAs =&ft_
noremap \_n :TCommentAs =&ft 
noremap \_a :TCommentAs 
noremap \_b :TCommentBlock
vnoremap <silent> \_r :TCommentRight
nnoremap <silent> \_r :TCommentRight
onoremap <silent> \_r :TCommentRight
vnoremap <silent> \_i :TCommentInline
noremap \_  :TComment 
noremap <silent> \_p vip:TComment
vnoremap <silent> \__ :TCommentMaybeInline
nnoremap <silent> \__ :TComment
onoremap <silent> \__ :TComment
map \rwp <Plug>RestoreWinPosn
map \swp <Plug>SaveWinPosn
map \tt <Plug>AM_tt
map \tsq <Plug>AM_tsq
map \tsp <Plug>AM_tsp
map \tml <Plug>AM_tml
map \tab <Plug>AM_tab
map \m= <Plug>AM_m=
map \t@ <Plug>AM_t@
map \t~ <Plug>AM_t~
map \t? <Plug>AM_t?
map \w= <Plug>AM_w=
map \ts= <Plug>AM_ts=
map \ts< <Plug>AM_ts<
map \ts; <Plug>AM_ts;
map \ts: <Plug>AM_ts:
map \ts, <Plug>AM_ts,
map \t= <Plug>AM_t=
map \t< <Plug>AM_t<
map \t; <Plug>AM_t;
map \t: <Plug>AM_t:
map \t, <Plug>AM_t,
map \t# <Plug>AM_t#
map \t| <Plug>AM_t|
map \T~ <Plug>AM_T~
map \Tsp <Plug>AM_Tsp
map \Tab <Plug>AM_Tab
map \T@ <Plug>AM_T@
map \T? <Plug>AM_T?
map \T= <Plug>AM_T=
map \T< <Plug>AM_T<
map \T; <Plug>AM_T;
map \T: <Plug>AM_T:
map \Ts, <Plug>AM_Ts,
map \T, <Plug>AM_T,o
map \T# <Plug>AM_T#
map \T| <Plug>AM_T|
map \Htd <Plug>AM_Htd
map \anum <Plug>AM_aunum
map \aunum <Plug>AM_aenum
map \afnc <Plug>AM_afnc
map \adef <Plug>AM_adef
map \adec <Plug>AM_adec
map \ascom <Plug>AM_ascom
map \aocom <Plug>AM_aocom
map \adcom <Plug>AM_adcom
map \acom <Plug>AM_acom
map \abox <Plug>AM_abox
map \a( <Plug>AM_a(
map \a= <Plug>AM_a=
map \a< <Plug>AM_a<
map \a, <Plug>AM_a,
map \a? <Plug>AM_a?
nnoremap \d :NERDTreeToggle
nnoremap \b :FuzzyFinderBuffer
nnoremap \f :FuzzyFinderFile
vmap ]% ]%m'gv``
vmap a% [%v]%
nmap gx <Plug>NetrwBrowseX
vnoremap <silent> gC :TCommentMaybeInline
nnoremap <silent> gCc :let w:tcommentPos = getpos(".") | set opfunc=tcomment#OperatorLineAnywayg@$
nnoremap <silent> gC :let w:tcommentPos = getpos(".") | set opfunc=tcomment#OperatorAnywayg@
vnoremap <silent> gc :TCommentMaybeInline
nnoremap <silent> gcc :let w:tcommentPos = getpos(".") | set opfunc=tcomment#OperatorLineg@$
nnoremap <silent> gc :let w:tcommentPos = getpos(".") | set opfunc=tcomment#Operatorg@
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
nmap <silent> <Plug>RestoreWinPosn :call RestoreWinPosn()
nmap <silent> <Plug>SaveWinPosn :call SaveWinPosn()
nmap <SNR>15_WE <Plug>AlignMapsWrapperEnd
map <SNR>15_WS <Plug>AlignMapsWrapperStart
vnoremap <C-Space> 
nnoremap <C-Up> 
nnoremap <C-Left> :bp
nnoremap <C-Right> :tabnext
map <S-Insert> <MiddleMouse>
inoremap s :TCommentAs =&ft_
inoremap n :TCommentAs =&ft 
inoremap a :TCommentAs 
inoremap b :TCommentBlock
inoremap <silent> r :TCommentRight
inoremap   :TComment 
inoremap <silent> p :norm! m`vip:TComment``
inoremap <silent>  :TComment
let &cpo=s:cpo_save
unlet s:cpo_save
set autoindent
set background=dark
set backspace=indent,eol,start
set backupdir=~/.vim/temp-files,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim/temp-files,~/.tmp,~/tmp,/var/tmp,/tmp
set expandtab
set fileencodings=ucs-bom,utf-8,default,latin1
set guifont=Liberation\ Mono\ 13
set guioptions=aegimrLtb
set helplang=en
set hidden
set history=50
set hlsearch
set nomodeline
set mouse=a
set path=.,/usr/include,,,/usr/local/lib/python2.6/dist-packages/windmill-1.1.1-py2.6.egg,/usr/local/lib/python2.6/dist-packages/functest-0.8.7-py2.6.egg,/usr/local/lib/python2.6/dist-packages/CherryPy-3.1.2-py2.6.egg,/usr/local/lib/python2.6/dist-packages/web.py-0.32-py2.6.egg,/usr/lib/python2.6,/usr/lib/python2.6/plat-linux2,/usr/lib/python2.6/lib-tk,/usr/lib/python2.6/lib-dynload,/usr/lib/python2.6/dist-packages,/usr/lib/python2.6/dist-packages/PIL,/usr/lib/python2.6/dist-packages/gst-0.10,/var/lib/python-support/python2.6,/usr/lib/python2.6/dist-packages/gtk-2.0,/var/lib/python-support/python2.6/gtk-2.0,/var/lib/python-support/python2.6/pyinotify,/usr/lib/python2.6/dist-packages/wx-2.8-gtk2-unicode,/usr/local/lib/python2.6/dist-packages
set printoptions=paper:letter
set ruler
set runtimepath=~/.vim,/var/lib/vim/addons,/usr/share/vim/vimfiles,/usr/share/vim/vim72,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/after
set shiftwidth=2
set showtabline=2
set smarttab
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set tabstop=2
set termencoding=utf-8
set window=31
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/MyLife/myapps/megauni
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +0 migrations/017_alter_news_images_aligns.rb
badd +0 migrations/013_alter_heart_link_images_to_amazon_s3s.rb
args migrations/017_alter_news_images_aligns.rb
edit migrations/017_alter_news_images_aligns.rb
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal balloonexpr=RubyBalloonexpr()
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal complete=.,w,b,u,t,i
setlocal completefunc=
setlocal nocopyindent
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal define=^\\s*#\\s*define
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'ruby'
setlocal filetype=ruby
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=^\\s*\\<\\(load\\|w*require\\)\\>
setlocal includeexpr=substitute(substitute(v:fname,'::','/','g'),'$','.rb','')
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=ri\ -T
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal nomodeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=rubycomplete#Complete
setlocal path=.,~/rubyee/lib/ruby/site_ruby/1.8,~/rubyee/lib/ruby/site_ruby/1.8/i686-linux,~/rubyee/lib/ruby/site_ruby,~/rubyee/lib/ruby/1.8,~/rubyee/lib/ruby/1.8/i686-linux,,~/rubyee/lib/ruby/gems/1.8/gems/ParseTree-2.1.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/ParseTree-2.1.1/test,~/rubyee/lib/ruby/gems/1.8/gems/ParseTree-3.0.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/ParseTree-3.0.4/test,~/rubyee/lib/ruby/gems/1.8/gems/RedCloth-4.2.2/ext,~/rubyee/lib/ruby/gems/1.8/gems/RedCloth-4.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/RedCloth-4.2.2/lib/case_sensitive_require,~/rubyee/lib/ruby/gems/1.8/gems/RubyInline-3.8.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/RubyInline-3.8.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/VimMate-0.6.6/lib,~/rubyee/lib/ruby/gems/1.8/gems/ZenTest-4.1.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/ZenTest-4.1.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/activerecord-2.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/activerecord-2.3.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/activesupport-2.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/activesupport-2.3.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/bacon-1.1.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/bcrypt-ruby-2.1.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/builder-2.1.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/cgi_multipart_eof_fix-2.5.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/chardet-0.9.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.10/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.11/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.12/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.13/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.15/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.16/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.8/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-960-plugin-0.9.7/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-960-plugin-0.9.8/lib,~/rubyee/lib/ruby/gems/1.8/gems/chronic-0.2.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/classifier-1.3.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/configuration-0.0.5/lib,~/rubyee/lib/ruby/gems/1.8/gems/daemons-1.0.10/lib,~/rubyee/lib/ruby/gems/1.8/gems/dbi-0.4.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/dbi-0.4.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/dependencies-0.0.6/lib,~/rubyee/lib/ruby/gems/1.8/gems/dependencies-0.0.7/lib,~/rubyee/lib/ruby/gems/1.8/gems/deprecated-2.0.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/devfu-rack-openid-proxy-0.1.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/diff-lcs-1.1.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/directory_watcher-1.2.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/eventmachine-0.12.8/lib,~/rubyee/lib/ruby/gems/1.8/gems/fastthread-1.0.7/ext,~/rubyee/lib/ruby/gems/1.8/gems/fastthread-1.0.7/lib,~/rubyee/lib/ruby/gems/1.8/gems/gem_plugin-0.2.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/grit-1.1.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/haml-2.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/haml-2.2.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/haml-2.2.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.0.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.2.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/highline-1.5.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/hoe-2.3.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/html5-0.10.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/htmlentities-4.0.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/htmlentities-4.1.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/htmlentities-4.2.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/jamis-fuzzy_file_finder-1.0.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/jekyll-0.4.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.7/ext,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.7/ext/json/ext,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.7/lib,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.9/ext,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.9/ext/json/ext,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.9/lib,~/rubyee/lib/ruby/gems/1.8/gems/launchy-0.3.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/liquid-2.0.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/loofah-0.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/markaby-0.
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=2
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.rb
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'ruby'
setlocal syntax=ruby
endif
setlocal tabstop=2
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal nowinfixheight
setlocal nowinfixwidth
set nowrap
setlocal nowrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 5 - ((4 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
5
normal! 043l
tabedit migrations/013_alter_heart_link_images_to_amazon_s3s.rb
set splitbelow splitright
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal keymap=
setlocal noarabic
setlocal autoindent
setlocal balloonexpr=RubyBalloonexpr()
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal complete=.,w,b,u,t,i
setlocal completefunc=
setlocal nocopyindent
setlocal nocursorcolumn
set cursorline
setlocal cursorline
setlocal define=^\\s*#\\s*define
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal expandtab
if &filetype != 'ruby'
setlocal filetype=ruby
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatexpr=
setlocal formatoptions=croql
setlocal formatlistpat=^\\s*\\d\\+[\\]:.)}\\t\ ]\\s*
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=^\\s*\\<\\(load\\|w*require\\)\\>
setlocal includeexpr=substitute(substitute(v:fname,'::','/','g'),'$','.rb','')
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keywordprg=ri\ -T
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal nomodeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal numberwidth=4
setlocal omnifunc=rubycomplete#Complete
setlocal path=.,~/rubyee/lib/ruby/site_ruby/1.8,~/rubyee/lib/ruby/site_ruby/1.8/i686-linux,~/rubyee/lib/ruby/site_ruby,~/rubyee/lib/ruby/1.8,~/rubyee/lib/ruby/1.8/i686-linux,,~/rubyee/lib/ruby/gems/1.8/gems/ParseTree-2.1.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/ParseTree-2.1.1/test,~/rubyee/lib/ruby/gems/1.8/gems/ParseTree-3.0.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/ParseTree-3.0.4/test,~/rubyee/lib/ruby/gems/1.8/gems/RedCloth-4.2.2/ext,~/rubyee/lib/ruby/gems/1.8/gems/RedCloth-4.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/RedCloth-4.2.2/lib/case_sensitive_require,~/rubyee/lib/ruby/gems/1.8/gems/RubyInline-3.8.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/RubyInline-3.8.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/VimMate-0.6.6/lib,~/rubyee/lib/ruby/gems/1.8/gems/ZenTest-4.1.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/ZenTest-4.1.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/activerecord-2.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/activerecord-2.3.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/activesupport-2.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/activesupport-2.3.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/bacon-1.1.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/bcrypt-ruby-2.1.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/builder-2.1.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/cgi_multipart_eof_fix-2.5.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/chardet-0.9.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.10/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.11/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.12/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.13/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.15/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.16/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-0.8.8/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-960-plugin-0.9.7/lib,~/rubyee/lib/ruby/gems/1.8/gems/chriseppstein-compass-960-plugin-0.9.8/lib,~/rubyee/lib/ruby/gems/1.8/gems/chronic-0.2.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/classifier-1.3.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/configuration-0.0.5/lib,~/rubyee/lib/ruby/gems/1.8/gems/daemons-1.0.10/lib,~/rubyee/lib/ruby/gems/1.8/gems/dbi-0.4.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/dbi-0.4.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/dependencies-0.0.6/lib,~/rubyee/lib/ruby/gems/1.8/gems/dependencies-0.0.7/lib,~/rubyee/lib/ruby/gems/1.8/gems/deprecated-2.0.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/devfu-rack-openid-proxy-0.1.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/diff-lcs-1.1.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/directory_watcher-1.2.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/eventmachine-0.12.8/lib,~/rubyee/lib/ruby/gems/1.8/gems/fastthread-1.0.7/ext,~/rubyee/lib/ruby/gems/1.8/gems/fastthread-1.0.7/lib,~/rubyee/lib/ruby/gems/1.8/gems/gem_plugin-0.2.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/grit-1.1.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/haml-2.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/haml-2.2.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/haml-2.2.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.0.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.2.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/heroku-1.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/highline-1.5.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/hoe-2.3.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/html5-0.10.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/htmlentities-4.0.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/htmlentities-4.1.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/htmlentities-4.2.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/jamis-fuzzy_file_finder-1.0.4/lib,~/rubyee/lib/ruby/gems/1.8/gems/jekyll-0.4.1/lib,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.7/ext,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.7/ext/json/ext,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.7/lib,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.9/ext,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.9/ext/json/ext,~/rubyee/lib/ruby/gems/1.8/gems/json-1.1.9/lib,~/rubyee/lib/ruby/gems/1.8/gems/launchy-0.3.3/lib,~/rubyee/lib/ruby/gems/1.8/gems/liquid-2.0.0/lib,~/rubyee/lib/ruby/gems/1.8/gems/loofah-0.2.2/lib,~/rubyee/lib/ruby/gems/1.8/gems/markaby-0.
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal quoteescape=\\
setlocal noreadonly
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=2
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal nospell
setlocal spellcapcheck=[.?!]\\_[\\])'\"\	\ ]\\+
setlocal spellfile=
setlocal spelllang=en
setlocal statusline=
setlocal suffixesadd=.rb
setlocal swapfile
setlocal synmaxcol=3000
if &syntax != 'ruby'
setlocal syntax=ruby
endif
setlocal tabstop=2
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal nowinfixheight
setlocal nowinfixwidth
set nowrap
setlocal nowrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 10 - ((9 * winheight(0) + 15) / 31)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
10
normal! 0
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
