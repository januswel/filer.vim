" vim plugin file
" Filename:     filer.vim
" Maintainer:   janus_wel <janus.wel.3@gmail.com>
"
" License:      MIT License {{{1
"   See under URL.  Note that redistribution is permitted with LICENSE.
"   https://github.com/januswel/filer.vim/blob/master/LICENSE

" preparations {{{1
" check if this plugin is already loaded or not
if exists('loaded_filer')
    finish
endif
let loaded_filer = 1

" check vim has required features
if !(has('multi_byte') && has('modify_fname'))
    finish
endif

" check the system has the required command
if !(has('mac') && executable('open'))
    finish
endif

" reset the value of 'cpoptions' for portability
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" main {{{1
" commands {{{2
" use exists() to check the command is already defined or not
" return value 2 tells that the command matched completely exists
if exists(':LaunchFiler') != 2
    command -nargs=? -complete=file LaunchFiler
                \ call s:LaunchFiler('<args>')
endif

" mappings {{{2
" check global variables that specify the plugin is allowed to define mappings
if !(exists('no_plugin_maps') && no_plugin_maps)
            \ && !(exists('no_filer_maps') && no_example_maps)

    " hasmapto() and <unique> are required to avoid overlap
    if !hasmapto('<Plug>LaunchFiler')
        nmap <unique><Leader>f <Plug>LaunchFiler
    endif
endif

" <script> and <SID> are used by vim internally
" consider to use :silent if you inhibit messages from vim
nnoremap <silent><Plug>LaunchFiler :call <SID>LaunchFiler()<CR>

" constants {{{2
let s:cmd = '!open'
lockvar s:cmd
let s:opt = '-R '
lockvar s:opt

" functions {{{2
function! s:LaunchFiler(...)
    try
        if empty(a:000)
            " lanch filer and select editing file
            let path = expand('%:p')
            if empty(path)
                " when buffer name is empty
                let path = getcwd()
            endif
        else
            let path = fnamemodify(a:1, ':p')
        endif

        if isdirectory(path)
            " when path is directory
            let dir = 1
        endif

        if exists('dir')
            let cmd = s:cmd . ' ' . shellescape(path)
        else
            let cmd = s:cmd . ' ' . s:opt . shellescape(path)
        endif

        let cmd = iconv(cmd, &encoding, jwlib#shell#GetEncoding())
        silent execute cmd
    catch
        echoerr v:exception
    endtry
endfunction

" post-processings {{{1
" restore the value of 'cpoptions'
let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" }}}1
" vim: ts=4 sw=4 sts=0 et fdm=marker fdc=3
