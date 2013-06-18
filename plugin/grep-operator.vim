" The Grep Operator plugin, inspired by Steve Losh and
" his book: http://learnvimscriptthehardway.stevelosh.com/
" Here are example mappings you should put in your .vimrc:
" nmap <unique> <Leader>g <Plug>GrepOperator
" vmap <unique> <Leader>g <Plug>GrepOperator

nnoremap <unique> <script> <Plug>GrepOperator <SID>GrepOperator
nnoremap <silent> <SID>GrepOperator :set operatorfunc=<SID>GrepOperator<cr>g@

vnoremap <unique> <script> <Plug>GrepOperator <SID>GrepOperator
vnoremap <silent> <SID>GrepOperator :<c-u>call <SID>GrepOperator(visualmode())<cr>

function! s:GrepOperator(type)
    " Can't use @ double quote, becase a double quote is a vim script comment
    let saved_unamed_register = @@

    if a:type ==# 'v'
        " Yank the last visual selection
        normal! gvy 
    elseif a:type ==# 'char'
        " Visually yank the motion
        normal! `[v`]y
    else
        " Anything that is not a characterwise visual selection or a
        " characterwise motion like visual block or linewise visual selection
        " will stop the script's execution
        return
    endif

    " Execute the command and don't jump to the first match (The :grep! form
    " does that)
    silent execute "grep! " . shellescape(@@) . " ."

    " Open the quick fix window
    copen

    " Restore the unamed register
    let @@ = saved_unamed_register
endfunction
