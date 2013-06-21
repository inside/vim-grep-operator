" The Grep Operator plugin, inspired by Steve Losh and
" his book: http://learnvimscriptthehardway.stevelosh.com/
" Here are example mappings you should put in your .vimrc:
" nmap <leader>g <Plug>GrepOperatorOnCurrentDirectory
" vmap <leader>g <Plug>GrepOperatorOnCurrentDirectory
" nmap <leader><leader>g <Plug>GrepOperatorWithFilenamePrompt
" vmap <leader><leader>g <Plug>GrepOperatorWithFilenamePrompt

" Mappings for the current directory grep
nnoremap <unique> <script> <Plug>GrepOperatorOnCurrentDirectory <SID>GrepOperatorOnCurrentDirectory
nnoremap <silent> <SID>GrepOperatorOnCurrentDirectory :set operatorfunc=<SID>GrepOperatorOnCurrentDirectory<cr>g@
vnoremap <unique> <script> <Plug>GrepOperatorOnCurrentDirectory <SID>GrepOperatorOnCurrentDirectory
vnoremap <silent> <SID>GrepOperatorOnCurrentDirectory :<c-u>call <SID>GrepOperatorOnCurrentDirectory(visualmode())<cr>

" Mappings with filenames prompt
nnoremap <unique> <script> <Plug>GrepOperatorWithFilenamePrompt <SID>GrepOperatorWithFilenamePrompt
nnoremap <silent> <SID>GrepOperatorWithFilenamePrompt :set operatorfunc=<SID>GrepOperatorWithFilenamePrompt<cr>g@
vnoremap <unique> <script> <Plug>GrepOperatorWithFilenamePrompt <SID>GrepOperatorWithFilenamePrompt
vnoremap <silent> <SID>GrepOperatorWithFilenamePrompt :<c-u>call <SID>GrepOperatorWithFilenamePrompt(visualmode())<cr>

function! s:GrepOperatorOnCurrentDirectory(type)
    call s:GrepOperator(a:type, 0)
endfunction

function! s:GrepOperatorWithFilenamePrompt(type)
    call s:GrepOperator(a:type, 1)
endfunction

function! s:GrepOperator(type, needs_prompt)
    " Can't use @", because a double quote is a vimscript comment
    let s:saved_unamed_register = @@
    let filenames = s:GetFilenames(a:needs_prompt)
    let pattern = s:GetPattern(a:type)

    " If the pattern is valid, call our grep function
    if len(pattern) > 0
        " Look the pattern in the given filenames
        call s:Grep(pattern, filenames)

        " Open the quick fix window
        copen
    endif

    " Restore the unamed register
    let @@ = s:saved_unamed_register
endfunction

function! s:GetPattern(type)
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
        return ''
    endif

    " returns the default register
    return @@
endfunction

function! s:Grep(pattern, filenames)
    " Execute the command and don't jump to the first match (The :grep! form
    " does that)
    silent execute 'grep! ' . shellescape(a:pattern) . ' ' . join(map(copy(a:filenames), "shellescape(v:val)"), ' ')
endfunction

function! s:GetFilenames(needs_prompt)
    if !a:needs_prompt
        return ['.']
    endif

    let base_prompt = "Enter one filename at a time or press <enter> to skip"
    let filenames = []

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

        call add(filenames, filename)
    endwhile

    return filenames
endfunction
