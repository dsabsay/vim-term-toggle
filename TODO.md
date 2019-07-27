# TODOs

## Bugs

- [ ] Fix window resizing issue with YouCompleteMe.
- [ ] Ctrl+s doesn’t seem to work
    - I suspect my readline bindings are not getting honored
- [ ] Ctrl+t is overlapping with something in ctrlp plugin
    - I think Ctrl+t ends up closing a window it shouldn’t
- [ ] [MINOR] When closing a terminal session, the numbering of the terminals may get skewed.
    - For example, starting with two terminals and closing the 0th would result in having 'term-toggle-1' occupying the '0' slot on the statusline "switcher".
    - As a solution, I could rename the buffer.
- [ ] When closing a terminal session, it's possible to end up with multiple buffers using the same name.
- [x] :TermClose doesn’t work
    - Weird behavior when closing terminal not at end of list
- [x] Fixed issue with Toggle (just fix s:AddNewTerm function reference)
- [x] Calling TermToggle the first time creates two windows (TermOpenWindow is called twice)
    - Simple fix for now is to not call TermSwitch at the end of AddNewTerm
- [x] If TermToggle is called before opening any files, the termnumber indicator in the statusline doesn’t work (i.e. the current terminal isn’t highlighted)

## Features

- [x] Implement AddNewTerm feature
- [ ] Implement shortcut to close all terminals?
