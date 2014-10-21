func! grep_operator#GrepOperatorOnCurrentDirectory(type) " {{{
  call s:GrepOperator(a:type, 0)
endf
" }}}

func! grep_operator#GrepOperatorWithFilenamePrompt(type) " {{{
  call s:GrepOperator(a:type, 1)
endf
" }}}

func! s:GrepOperator(type, needs_prompt) " {{{
  " Can't use @", because a double quote is a vimscript comment
  let saved_unamed_register = @@
  let filenames = s:GetFilenames(a:needs_prompt)
  let pattern = s:GetPattern(a:type)

  " If the pattern is valid, call our grep function
  if len(pattern) > 0
    " Look the pattern in the given filenames
    call s:Grep(pattern, filenames)

    " Open the quick fix window
    copen
    " Prevents the terminal from hiding characters
    " This appends sometimes when using external commands
    " See :help various.txt|528
    redraw!
  endif

  " Restore the unamed register
  let @@ = saved_unamed_register
endf
" }}}

func! s:GetPattern(type) " {{{
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
endf
" }}}

func! s:IsPreferredOperatorAvailable(operator) " {{{
  return exists(':' . a:operator) > 0
endf
" }}}

func! s:Grep(pattern, filenames) " {{{
  " Get the operator specified by the user
  let operator = get(g:, 'grep_operator', 'grep')
  if !s:IsPreferredOperatorAvailable(operator)
    " If it's not available fallback to grep
    let operator = 'grep'
  endif

  " Execute the command and don't jump to the first match (The :grep! form
  " does that)
  silent execute
        \ operator . '! ' . shellescape(a:pattern, 1) . ' ' .
        \ join(map(copy(a:filenames), 'shellescape(v:val)'), ' ')
endf
" }}}

func! s:GetFilenames(needs_prompt) " {{{
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
endf
" }}}
