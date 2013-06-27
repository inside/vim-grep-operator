# The vim grep operator

## Description

The vim grep operator plugin, inspired by Steve Losh and
his book: http://learnvimscriptthehardway.stevelosh.com/

This plugin's has 2 goals:

* bring motion and visual selection to the :grep command
* open the quickfix window on the fly for easy file match navigation

## Installation

Use pathogen or a pathogen compatible plugin manager.

If you are using git for source code management, you should have your grepprg
option set to something like this:

    set grepprg=git\ grep\ -n\ $*

## Suggested ~/.vimrc mappings

    nmap <leader>g <Plug>GrepOperatorOnCurrentDirectory
    vmap <leader>g <Plug>GrepOperatorOnCurrentDirectory
    nmap <leader><leader>g <Plug>GrepOperatorWithFilenamePrompt
    vmap <leader><leader>g <Plug>GrepOperatorWithFilenamePrompt

## Examples

`<leader>giw` will grep the current directory for the word under the cursor and
open the quickfix window.

`<leader>ga(` will grep for what's inside the parenthesis including the
parenthesis.

`<leader>gi'` will grep for what's inside the quotes.

Visually select some characters and type `<leader>g`. This will grep for the
selected text.

You can also be prompted for files to grep by using the same motions or visual
selection but with the `<leader><leader>g` mapping.

## Useful readings

`:h grepprg`
`:h quickfix`
`:h text-objects`
http://learnvimscriptthehardway.stevelosh.com/ and specifically chapters 32, 33, 34
