# vim-popselect

ファイルなどをポップアップウインドウで選択して開くやつ
![popselect-min-half-min](https://github.com/user-attachments/assets/b9996b2e-2936-4168-9c5d-6ac4264a5d3f)

Note: これは個人的に使っている設定をプラグインの形に切り出しただけで
万人向けに作られたプラグインではありません

よって以下です

- 動作は個人の好み
- 頻度の低いバグや副作用は放置
- 破壊的変更が良くはいる
- ドキュメンは気が向いたときに
- README.mdは日本語

## Required

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
nnoremap <C-p> <ScriptCmd>popselect#projectfiles#PopupMruAndProjectFiles()<CR>
```

### リストボックス
- 移動 `j`, `<C-n>`, `k`, `<C-p>`, `<C-f>`, `<C-b>`, `G`, `g`(=`gg`)
- 決定 `<CR>`
- 表示中の下一桁のアイテムを選択して決定 `0`-`9`
- タブで開く `t`, `<C-t>`
- フィルターにフォーカスする `f`, `/`, `<Tab>`

Note: `tabpages#Popup()`は`t`, `T`が移動になります
Note: `buffers#Popup()`, `tabpages#Popup()`は移動時即座に開きます

### フィルター部分
- リスト移動 `<C-n>`, `<C-p>`, `<C-f>`, `<C-b>`
- 決定 `<CR>`
- タブで開く `<C-t>`
- リストボックスにフォーカスする `<Tab>`

Note: `popselect#projectfiles#Popup()`, `popselect#projectfiles#PopupMruAndProjectFiles()`はフィルターにフォーカスした状態で起動します(個人の好み)

## Settings
Exmaple
```
vim9script
g:popselect = {
	maxwidth: 40,
}
```
See `defaultSettings` in [autoload/popselect.vim](autoload/popselect.vim)

## Popup Cutomized list
Examples
[autoload/popselect/*.vim](autoload/popselect)

