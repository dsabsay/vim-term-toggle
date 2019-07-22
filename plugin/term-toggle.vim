let s:terms = []  " List of buffer numbers
let s:currentTerm = -1  " Index into terms
let s:termIsOpen = 0
let s:termWindowNum = -1
let g:term_toggle_default_height = 10

" TODO: need to handle when a terminal buffer is closed (e.g. exiting the
" shell). Need to remove from terms list and set termIsOpen to false.

" TODO: Use <Plug> to provide default keybindings OR just provide public
" functions

noremap <leader>t :call TermToggle()<CR>
command! -nargs=1 TermSwitch :call TermSwitch(<args>)
noremap <leader>t0 :call TermSwitch(0)
noremap <leader>t1 :call TermSwitch(1)
noremap <leader>t2 :call TermSwitch(2)

" Moves cursor to terminal window.
function TermFocus()
    if s:termIsOpen
        execute s:termWindowNum . 'wincmd w'
    endif
endfunction

" Switches to the terminal identified by <termNum>.
function TermSwitch(termNum)
    if a:termNum < 0 || a:termNum > len(s:terms) - 1
        return
    endif

    let s:currentTerm = a:termNum
    setlocal bufhidden=hide
    execute 'buffer! ' . s:terms[s:currentTerm]
    setlocal statusline=%!TermToggleStatusLine()
endfunction

" Toggles the terminal window on/off.
function TermToggle()
    if s:termIsOpen
        let s:termIsOpen = 0
        execute s:termWindowNum . 'hide'
    else
        call s:TermOpenWindow()
    endif
endfunction

" Closes the current terminal session.
function TermClose()

    if len(s:terms) == 1
        bdelete!
        let s:terms = []
        let s:currentTerm = -1
        let s:termIsOpen = 0
    else
        bdelete!
        let s:terms = s:terms[0:s:currentTerm - 1] + s:terms[s:currentTerm + 1:]
        let s:currentTerm = len(s:terms) - 1
        let s:termIsOpen = 0  " bdelete will have closed the window
        call TermToggle()
    endif
endfunction

" Opens a window for the terminal. Sets all appropriate state.
function s:TermOpenWindow()
    if s:termIsOpen
        return
    endif

    if len(s:terms) == 0  " Create a term if none exist yet
        call AddNewTerm()
    endif

    let s:termIsOpen = 1
    execute 'bot ' . g:term_toggle_default_height . 'new'
    execute 'buffer ' . s:terms[s:currentTerm]
    let s:termWindowNum = winnr()
    setlocal statusline=%!TermToggleStatusLine()
endfunction

" Builds the statusline and returns it as a string.
function TermToggleStatusLine()
    let sl = ''

    let sl = sl . '%{&shell}'  " Name of shell
    let sl = sl . ' [Terminal]'
    let sl = sl . '%='  " Align next items to right

    let index = 0
    for term in s:terms
        if index == s:currentTerm
            " let sl+=\ %#Normal#\ 🖥\ %#Terminal#
            let sl = sl . '%#Normal#'
            let sl = sl . ' ' . index . ' '
            let sl = sl . '%#Terminal#'
        else
            " let sl+=\ 🖥
            let sl = sl . ' ' . index . ' '
        endif
        let index += 1
    endfor

    let sl = sl . '  |  %l,%c'  " line number, column number

    return sl
endfunction

" Creates a new terminal buffer and appends it to the terms list. Does not
" create a window.
function AddNewTerm()
    let options = {
        \ 'term_name': 'term-toggle-' . len(s:terms),
        \ 'term_finish': 'open',
        \ 'hidden': 1,
    \ }
    let bufNum = term_start(&shell, options)
    let s:terms = add(s:terms, bufNum)
    let s:currentTerm = len(s:terms) - 1
endfunction

function Test()
    call AddNewTerm()
    call AddNewTerm()
    call AddNewTerm()
    call TermToggle()
endfunction
