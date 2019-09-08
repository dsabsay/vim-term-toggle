" User-configurable settings
let g:term_toggle_disable_default_mappings = 0
let g:term_toggle_default_height = 10
let g:term_toggle_switch_mapping = 0

" Commands
" These commands represent the "public" API.
command TermClose :call s:TermClose()
command TermToggle :call s:TermToggle()
command -nargs=1 TermSwitch :call s:TermSwitch(<args>)
command TermNew :call s:AddNewTerm()

" Create mappings
if g:term_toggle_disable_default_mappings == 0
    tmap <c-t> <c-w>:TermToggle<CR>
    nmap <c-t> :TermToggle<CR>

    " Create default TermSwitch mappings
    for i in range(10)
        execute 'tmap ' . "<C-w>" . i . " <c-w>" . ':TermSwitch ' . i . "<CR>"
    endfor
elseif g:term_toggle_switch_mapping
    " Create user-configured mapping
    for i in range(10)
        execute 'tmap ' . g:term_toggle_switch_mapping . i . " <c-w>" . ':TermSwitch ' . i . "<CR>"
    endfor
endif



" Internal state
let s:terms = []  " List of buffer numbers
let s:currentTerm = 0  " Index into terms
let s:termIsOpen = 0
let s:termWindowID = -1

" TODO: need to handle when a terminal buffer is closed (e.g. exiting the
" shell). Need to remove from terms list and set termIsOpen to false.


" Moves cursor to terminal window.
function TermFocus()
    if s:termIsOpen
        execute win_id2win(s:termWindowID) . 'wincmd w'
    endif
endfunction

" Switches to the terminal identified by <termNum>.
function s:TermSwitch(termNum)
    if a:termNum < 0 || a:termNum > len(s:terms) - 1
        return
    endif

    if s:termIsOpen == 0
        call s:TermOpenWindow()
    endif

    let s:currentTerm = a:termNum
    setlocal bufhidden=hide
    execute 'buffer! ' . s:terms[s:currentTerm]
    setlocal statusline=%!TermToggleStatusLine()
endfunction

" Toggles the terminal window on/off.
function s:TermToggle()
    if s:termIsOpen
        let s:termIsOpen = 0
        execute win_id2win(s:termWindowID) . 'hide'
        return
    endif

    if len(s:terms) == 0  " Create a term if none exist yet
        call s:AddNewTerm()
    endif
    call s:TermOpenWindow()
endfunction

" Returns a copy of list with the item at index removed.
" index must be a positive number less than the length of the list.
function s:Remove(index, list)
    if a:index < 0 || a:index > len(a:list) - 1
        throw "remove(): Invalid index."
    endif

    if a:index == 0
        return a:list[1:]
    endif

    return a:list[:a:index - 1] + a:list[a:index + 1:]
endfunction

" Closes the current terminal session.
function s:TermClose()
    if len(s:terms) == 1
        bdelete!
        let s:terms = []
        let s:currentTerm = -1
        let s:termIsOpen = 0
    else
        let s:terms = s:Remove(s:currentTerm, s:terms)
        echom "s:terms: " . join(s:terms, ", ")
        let s:currentTerm = len(s:terms) - 1
        bdelete!
        let s:termIsOpen = 0  " bdelete will have closed the window
        call s:TermToggle()
    endif
endfunction

" Opens a window for the terminal. Sets all appropriate state.
function s:TermOpenWindow()
    if s:termIsOpen
        return
    endif

    let s:termIsOpen = 1
    execute 'bot ' . g:term_toggle_default_height . 'new'
    execute 'buffer ' . s:terms[s:currentTerm]
    let s:termWindowID = win_getid()
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
function s:AddNewTerm()
    let options = {
        \ 'term_name': 'term-toggle-' . len(s:terms),
        \ 'term_finish': 'open',
        \ 'hidden': 1,
    \ }
    let bufNum = term_start(&shell, options)
    let s:terms = add(s:terms, bufNum)
endfunction
