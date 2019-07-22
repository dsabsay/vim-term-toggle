# Goals

The built-in terminal in Vim 8 is very convenient. But I wish it was a bit easier to integrate into my workflow. The goal of this plugin is to provide a few simple features to do exactly that. Namely, the short-term goals of this plugin are as follows:

* Provide an easy way to toggle a terminal window on/off (through a global function that a user can alias to any keybindings they like).
* Provide an easy way to manage multiple terminal sessions.
    * TermSwitch <num>
* Show a visual indicator of the terminal sessions.
    * One possbility is to use the statusline.
* Prevent terminal windows from resizing automatically after completions, etc.
