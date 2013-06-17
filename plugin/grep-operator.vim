" The Grep Operator plugin, inspired by Steve Losh and
" his book: http://learnvimscriptthehardway.stevelosh.com/

nnoremap <leader>G :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <leader>G :<c-u>call <SID>GrepOperator(visualmode())<cr>

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
    silent execute "grep! -R " . shellescape(@@) . " ."

    " Open the quick fix window
    copen

    " Restore the unamed register
    let @@ = saved_unamed_register
endfunction
