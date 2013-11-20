fun! URLEncode(params)
  let params = system("echo $(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' \"" . a:params . "\")")
  return params
endfun

fun! RunQunit()
  let test_name = getline(1)
  let test_name = substitute(test_name, "module \"", '', '')
  let test_name = substitute(test_name, "\",", '', '')
  let test_name = URLEncode(test_name)
  let test_name = shellescape(test_name, 1)
  let test_name = substitute(test_name, "\\n\'", '', '')
  let test_name = substitute(test_name, "\'", '', '')

  let url = "http://localhost:3000/qunit?module=" . test_name
  silent! exec "silent! !open " . url | redraw!

endfun

command! -nargs=* -range RunQunit :call RunQunit()
nnoremap <leader>j :RunQunit<CR>

" forcused application enabled 1:True 0:False
if !exists('g:returnAppFlag')
  let g:returnAppFlag = 0
endif 

" forcused application name after browser reload
if !exists('g:returnApp')
  let g:returnApp = ""
endif 

" default  browser reload command
if !exists('g:defaultReloadCmd')
  let g:defaultReloadCmd = " -e 'tell application \"System Events\"'"
\                        . " -e '    if UI elements enabled then'"
\                        . " -e '        key down command'"
\                        . " -e '        keystroke \"r\"'"
\                        . " -e '        key up command'"
\                        . " -e '    end if'"
\                        . " -e 'end tell'"
endif

" display command error
if !exists('g:debugMode')
  let g:debugMode = 0 " 0:debug mode off. 1:debug mode on. 
endif 

func! s:Reload(app, ...)
    let l:appcmd    = "osascript -e 'tell app \"" . a:app . "\" to activate'"
    let l:returncmd = " -e 'tell app \"" . g:returnApp . "\" to activate'"
    let l:devnull = g:debugMode ? " " : "> /dev/null 2>&1"

    if a:0
        let l:reloadcmd = " -e '" . a:1 . "'"
    else
        let l:reloadcmd = g:defaultReloadCmd
    endif

    let l:execcmd = l:appcmd . l:reloadcmd . l:devnull

    silent! exec "silent !" . l:execcmd

    redraw!
endfunc

command! -bar ChromeReload call s:Reload("Google Chrome", 'tell application "Google Chrome" to reload active tab of window 1') 
command! -bar ChromeReloadStart ChromeReloadStop | autocmd BufWritePost <buffer> ChromeReload
command! -bar ChromeReloadStop autocmd! BufWritePost <buffer>

nnoremap <leader>r :ChromeReload<CR>
