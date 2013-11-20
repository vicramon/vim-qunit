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
nnoremap <leader>e :RunQunit<CR>

func! s:Reload(app, ...)
    let l:appcmd    = "osascript -e 'tell app \"" . a:app . "\" to activate'"
    let l:reloadcmd = " -e '" . a:1 . "'"
    let l:execcmd = l:appcmd . l:reloadcmd

    silent! exec "silent !" . l:execcmd | redraw!
endfunc

command! -bar ChromeReload call s:Reload("Google Chrome", 'tell application "Google Chrome" to reload active tab of window 1') 
command! -bar ChromeReloadStart ChromeReloadStop | autocmd BufWritePost <buffer> ChromeReload
command! -bar ChromeReloadStop autocmd! BufWritePost <buffer>

nnoremap <leader>r :ChromeReload<CR>
