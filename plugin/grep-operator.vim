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
    " Can't use @", because a double quote is a vimscript comment
    let saved_unamed_register = @@
    let filenames = []
    let base_prompt = "Enter one filename at a time or press <enter> to skip"

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

    while 1
        if empty(filenames)
            let prompt = base_prompt . ': '
        else
            let prompt = printf(base_prompt . ' (%s): ', join(filenames, ', '))
        endif

        call inputsave()
        let filename = input(prompt, '', 'file')
        call inputrestore()

        if len(filename) == 0
            break
        endif

        call add(filenames, shellescape(filename))
    endwhile

    " Execute the command and don't jump to the first match (The :grep! form
    " does that)
    if empty(filenames)
        " grep in the current directory
        silent execute 'grep! ' . shellescape(@@) . ' .'
    else
        " grep in the listed directories
        silent execute 'grep! ' . shellescape(@@) . ' ' . join(filenames, ' ')
    endif

    " Open the quick fix window
    copen

    " Restore the unamed register
    let @@ = saved_unamed_register
endfunction
