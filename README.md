# vim-popselect

Open buffers, tab pages, MRU and more with popup window.
![popselect-min-half-min](https://github.com/user-attachments/assets/b9996b2e-2936-4168-9c5d-6ac4264a5d3f)

Note: This is just a cutout of my personal settings in plugin form.
It is not a plugin designed for everyone.

So here this is

- The behavior is a personal preference.
- Infrequent bugs and side-effects are left out
- Destructive changes are common.
- Documentation is written when I feel like it

## Requirements

Vim head

Note: This does not support Neovim.


and [vim-nerdfont](https://github.com/lambdalisue/vim-nerdfont)

## Usage
Example
```
vim9script
packadd vim-popselect
nnoremap <F1> <ScriptCmd>popselect#dir#Popup()<CR>
nnoremap <F2> <ScriptCmd>popselect#mru#Popup()<CR>
nnoremap <F3> <ScriptCmd>popselect#buffers#Popup()<CR>
nnoremap <F4> <ScriptCmd>popselect#tabpages#Popup()<CR>
nnoremap <C-p> <ScriptCmd>popselect#projectfiles#PopupMruAndProjectFiles({ filter_focused: true })<CR>
```

### List box
- Move: `j`, `<C-n>`, `k`, `<C-p>`, `<C-f>`, `<C-b>`, `G`, `g`(=`gg`)
- Open: `<CR>`
- Select with last digit and open: `0`-`9`
- Open with a new tab: `t`, `<C-t>`
- Close: `q`, `d`(Buffers and Tab pages)
- Focus the filter input box: `f`, `/`, `<Tab>`

Note: You can move with `t` and `T` in `tabpages#Popup()`.  
Note: `buffers#Popup()` and `tabpages#Popup()` open it on move.

### Filter input box
- Move: `<C-n>`, `<C-p>`, `<C-f>`, `<C-b>`
- Open: `<CR>`
- Open with a new tab: `<C-t>`
- Focus the list box: `<Tab>`

## Settings
Exmaple
```
vim9script
g:popselect = {
	maxwidth: 40,
}
```
See `default_settings` in [autoload/popselect.vim](autoload/popselect.vim).

## Popup your cutomized list
Examples
[autoload/popselect/*.vim](autoload/popselect)

