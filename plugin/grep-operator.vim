" File:        grep-operator.vim
" Maintainer:  Yann Thomas-Gérard <inside at gmail dot com>
" Version:     0.0.1
" License:     This file is placed in the public domain.

" Mappings for the current directory grep {{{
nnoremap
            \ <script>
            \ <Plug>GrepOperatorOnCurrentDirectory
            \ <SID>GrepOperatorOnCurrentDirectory
nnoremap
            \ <silent>
            \ <SID>GrepOperatorOnCurrentDirectory
            \ :set operatorfunc=<SID>GrepOperatorOnCurrentDirectory<cr>g@
vnoremap
            \ <script>
            \ <Plug>GrepOperatorOnCurrentDirectory
            \ <SID>GrepOperatorOnCurrentDirectory
vnoremap
            \ <silent>
            \ <SID>GrepOperatorOnCurrentDirectory
            \ :<c-u>call <SID>GrepOperatorOnCurrentDirectory(visualmode())<cr>
" }}}

" Mappings with filenames prompt {{{
nnoremap
            \ <script>
            \ <Plug>GrepOperatorWithFilenamePrompt
            \ <SID>GrepOperatorWithFilenamePrompt
nnoremap
            \ <silent>
            \ <SID>GrepOperatorWithFilenamePrompt
            \ :set operatorfunc=<SID>GrepOperatorWithFilenamePrompt<cr>g@
vnoremap
            \ <script>
            \ <Plug>GrepOperatorWithFilenamePrompt
            \ <SID>GrepOperatorWithFilenamePrompt
vnoremap
            \ <silent>
            \ <SID>GrepOperatorWithFilenamePrompt
            \ :<c-u>call <SID>GrepOperatorWithFilenamePrompt(visualmode())<cr>
" }}}

function! s:GrepOperatorOnCurrentDirectory(type) " {{{
    call s:GrepOperator(a:type, 0)
endfunction
" }}}

function! s:GrepOperatorWithFilenamePrompt(type) " {{{
    call s:GrepOperator(a:type, 1)
endfunction
" }}}

function! s:GrepOperator(type, needs_prompt) " {{{
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
" }}}

function! s:GetPattern(type) " {{{
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
" }}}

function! s:Grep(pattern, filenames) " {{{
    " Execute the command and don't jump to the first match (The :grep! form
    " does that)
    silent execute
                \ 'grep! '
                \ . shellescape(a:pattern) . ' '
                \ . join(map(copy(a:filenames), "shellescape(v:val)"), ' ')
endfunction
" }}}

function! s:GetFilenames(needs_prompt) " {{{
    if !a:needs_prompt
        return ['.']
    endif

    let base_prompt = "Enter filenames or empty string"
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
" }}}
