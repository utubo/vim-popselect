vim9script

silent! packadd nerdfont.vim

var popselect_id = 0
var winid = 0
var filter_winid = 0
var filter_text = ''
var filter_visible = false
var filter_focused = false
var filter_withdigit = {}
var line_offset = 0
var has_icon = false
var has_shortcut = false
var src = []
var items = []
var opts = {}
var blink_timer = 0
var blink = false
var hl_cursor = []
var hl_popselect_cursor = []

var default_settings = {
  maxwidth: 60,
  maxheight: 9,
  tabstop: 2,
  limit: 300,
  filter_focused: false,
  want_space: true,
  want_number: true,
  extra_show: true,
  extra_col: 20,
  icon_term: "\uf489",
  icon_unknown: "\uea7b",
  icon_diropen: "\ue5fe",
  icon_dirgit: "\ue5fb",
  icon_dirup: "\uf062",
  projectfiles_ignore_dirs: [
    'node_modules',
    'dist',
    'build',
    '.*',
  ],
  projectfiles_root_anchor: [
    '.git',
    'package.json',
    'deno.json',
    'pom.xml',
    'build.gradle',
    'README.md',
  ],
  projectfiles_depth: 5,
}
g:popselect = default_settings->extend(get(g:, 'popselect', {}))

def Nop(...args: list<any>): bool
  return false
enddef

def GetPos(): number
  return getcurpos(winid)[1]
enddef

def Item(): any
  return items[GetPos() - 1]
enddef

def Update()
  var text = []
  if filter_visible && filter_text !=# ''
    items = matchfuzzy(src, filter_text, { text_cb: (i) => $"{i.label}\<Tab>{get(i, 'extra', '')}" })
    if filter_withdigit !=# {}
      const i = (items)->indexof((_, v) => (opts.getkey(v) ==# opts.getkey(filter_withdigit)))
      if i !=# -1
        items->remove(i)
      endif
      items = [filter_withdigit] + items
    else
      line_offset = 0
    endif
  else
    items = src->copy()
    line_offset = 0
  endif
  var n = line_offset
  for item in items
    n += 1
    var icon = ''
    if has_icon
      icon = item.icon ?? g:popselect.icon_unknown
    endif
    var label = item.label
    const extra = opts.extra_show ? get(item, 'extra', '') : ''
    if !!extra
      const c = opts.extra_col - opts.tabstop
      if label->strdisplaywidth() < c
        label = (label .. repeat(' ', c))->matchstr($'.*\%{c}v')
      endif
      label ..= $"\<Tab>{extra}"
    endif
    var s = $'{n}'
    var offset = ''
    if item->has_key('shortcut')
      s = $'{item.shortcut->keytrans()}:'
    elseif n <= 9 && 9 < items->len()
      offset = ' '
    endif
    text += [$'{offset}{s} {icon}{label}']
  endfor
  popup_settext(winid, text)
  var padding_top = filter_visible && !!text ? 1 : 0
  popup_setoptions(winid, {
    padding: [padding_top, 1, 0, 1],
    maxheight: min([g:popselect.maxheight, &lines - 2 - padding_top]),
  })
  if filter_visible
    var cursor = ''
    if filter_focused
      hi link PopSelectFilterNow PopSelectFilter
      cursor = ' '
    else
      hi link PopSelectFilterNow PopSelectFilterNC
    endif
    const filtertext = $'Filter:{filter_text}{cursor}'
    const p = popup_getpos(winid)
    const width = max([p.core_width, strdisplaywidth(filtertext)])
    popup_move(winid, { minwidth: width })
    popup_move(filter_winid, {
       col: p.core_col,
       line: p.core_line - (!text ? 0 : 1),
       maxwidth: width,
       minwidth: width,
       zindex: 2,
    })
    popup_show(filter_winid)
    popup_settext(filter_winid, filtertext)
  else
    popup_hide(filter_winid)
  endif
enddef

def Filter(id: number, key: string): bool
  if key ==# "\<CursorHold>"
    return false
  elseif opts.filter_user(id, key)
    return true
  elseif len(key) !=# 1 && key !=# "\<BS>" && key !=# "\<S-Tab>"
    Close()
    return true
  endif
  if key =~# "[\<ESC>\<C-x>]"
    Close()
    return true
  elseif key ==# "\<CR>"
    Complete()
    return true
  elseif key ==# "\<C-t>"
    WithTab()
    return true
  elseif key =~# "[\<C-n>\<C-p>\<C-f>\<C-b>]"
    Move(key)
    return true
  endif
  if filter_focused
    if !g:popselect.want_space && key ==# "\<Space>"
      Complete()
      return true
    endif
    if !g:popselect.want_number && !filter_text && key =~# '[0-9]'
      GetIndexWithDigit(key)->Select()
      Complete()
      return true
    endif
    if key ==# "\<Tab>" || key ==# "\<S-Tab>"
      filter_focused = false
    elseif key ==# "\<BS>"
      filter_text = filter_text->substitute('.$', '', '')
      filter_withdigit = {}
    elseif key !~# '^\p$'
      Close()
      return true
    else
      if key =~# '[0-9]'
        const index = GetIndexWithDigit(key)
        filter_withdigit = get(items, index - line_offset - 1, {})
        line_offset = index - 1
      else
        filter_withdigit = {}
      endif
      filter_text ..= key
      Select(1)
    endif
    Update()
    return true
  endif
  const onkey_N = $'onkey_{key}'
  if opts->has_key(onkey_N)
    funcref(opts[onkey_N], [Item()])()
    return true
  endif
  if key ==# "\<Space>"
    Complete()
    return true
  endif
  if has_shortcut
    const index = GetIndexWithShortcut(key)
    if index !=# -1
      Select(index)
      Complete()
      return true
    endif
  endif
  if key =~# '[njbpkBgG]'
    Move(key)
  elseif key =~# '[0-9]'
    const index = GetIndexWithDigit(key)
    Select(index)
    Complete()
  elseif key =~# '[eo]'
    Complete()
  elseif key ==# 't'
    WithTab()
  elseif key =~# '[qd]' &&
      (opts.ondelete !=# Nop || opts.predelete !=# Nop)
    Delete(Item())
  elseif key =~# '[f/]'
    if opts.filter_focused !=# 'never'
      filter_visible = !filter_visible
      filter_focused = filter_visible
      Update()
    endif
  elseif key ==# "\<Tab>" || key ==# "\<S-Tab>"
    if opts.filter_focused !=# 'never'
      filter_visible = true
      filter_focused = filter_visible
      Update()
    endif
  else
    Close()
  endif
  return true
enddef

def Delete(item: any)
  if opts.predelete(item)
    return
  endif
  opts.ondelete(item)
  src->remove(
    (src) ->  indexof((_, v) => (opts.getkey(v) ==# opts.getkey(item)))
  )
  for i in range(src->len())
    src[i].index = i + 1
  endfor
  if src->len() < 1
    Close()
  else
    Update()
    OnSelect()
  endif
enddef

def SetupItems(from: number = 0): number
  var selectedIndex = 1
  for i in range(from, src->len() - 1)
    var item = src[i]
    if type(item) ==# v:t_string
      item = { label: item }
      src[i] = item
    endif
    if get(item, 'selected', false)
      selectedIndex = i + 1
    endif
    item.index = i + 1
    has_icon = has_icon || item->has_key('icon')
    has_shortcut = has_shortcut || item->has_key('shortcut')
  endfor
  return selectedIndex
enddef

export def Add(new_items: list<any>)
  const from = src->len()
  src += new_items
  from->SetupItems()
  Update()
enddef

def Select(line: number)
  win_execute(winid, $':{line}')
  OnSelect()
enddef

def GetIndexWithShortcut(key: string): number
  return items->indexof((i, v) => get(v, 'shortcut', '') ==# key)
enddef

def GetIndexWithDigit(d: string): number
  var index = str2nr(d)
  const s = popup_getpos(winid).firstline - line_offset
  while index < s
    index += 10
  endwhile
  return index
enddef

export def Move(key: any)
  var k = key
  if k =~# "[p\<C-p>]"
    k = 'k'
  elseif k =~# "[n\<C-n>]"
    k = 'j'
  endif
  var p = GetPos()
  if k ==# 'k' && p <= 1
    k = 'G'
  elseif k ==# 'g' || k ==# 'j' && items->len() <= p
    k = 'gg'
  endif
  win_execute(winid, $'normal! {k}')
  OnSelect()
enddef

def OnComplete(item: any)
  if item->has_key('target')
    execute 'edit' item.target
  endif
enddef

def Complete()
  if items->len() < 1
    return
  endif
  const item = Item()
  if opts.precomplete(item)
    return
  endif
  Close()
  opts.oncomplete(item)
enddef

def OnTabpage(item: any)
  if item->has_key('target')
    execute 'tabedit' item.target
  endif
enddef

def WithTab()
  if items->len() < 1
    return
  endif
  const item = Item()
  Close()
  opts.ontabpage(item)
enddef

def OnSelect()
  if items->len() < 1
    return
  endif
  opts.onselect(Item())
enddef

export def Id(): number
  return popselect_id
enddef

export def Popup(what: list<any>, options: any = {}): number
  if what->len() < 1
    return 0
  endif
  opts = {
    zindex: 1,
    tabpage: -1,
    mapping: false,
    filter: Nop,
    filter_text: '',
    oncomplete: OnComplete,
    ontabpage: OnTabpage,
    onselect: Nop,
    ondelete: Nop,
    precomplete: Nop,
    predelete: Nop,
    getkey: (item) => item.index,
  }
  opts->extend(g:popselect)->extend(options)
  opts.filter_user = opts.filter
  opts.filter = Filter
  opts.maxheight = min([opts.maxheight, &lines - 2])
  opts.maxwidth = min([opts.maxwidth, &columns - 5])
  # List box
  has_icon = false
  has_shortcut = false
  src = what->copy()
  src = src[0 : opts.limit + 1]
  const selectedIndex = SetupItems()
  winid = popup_menu([], opts)
  win_execute(winid, $'syntax match PMenuKind /^\s*\d\+ {has_icon ? '.' : ''}/')
  win_execute(winid, 'syntax match PMenuExtra /\t.*$/')
  win_execute(winid, $'setlocal tabstop={opts.tabstop}')
  # Filter input box
  filter_text = opts.filter_text
  opts.filter_focused = $'{opts.filter_focused}'
  if opts.filter_focused ==# 'never'
    filter_focused = false
  elseif opts.filter_focused !=# 'keep'
    filter_focused = opts.filter_focused ==# 'true'
  endif
  filter_visible = filter_focused
  hi default link PopSelectFilter Normal
  hi default link PopSelectFilterNC PmenuExtra
  hi link PopSelectFilterNow PopSelectFilter
  filter_winid = popup_create('', { highlight: 'PopSelectFilterNow' })
  HideCursor()
  # Show
  Update()
  win_gotoid(winid)
  Select(selectedIndex)
  popselect_id = localtime()
  return popselect_id
enddef

export def Close()
  augroup popselect
    au!
  augroup END
  timer_stop(blink_timer)
  RestoreCursor()
  popup_close(winid)
  popup_close(filter_winid)
  winid = 0
  filter_winid = 0
  popselect_id = 0
enddef

def HideCursor()
  augroup popselect
    au!
    au VimLeavePre * RestoreCursor()
  augroup END
  set t_ve=
  hl_cursor = hlget('Cursor')
  hl_popselect_cursor = [hl_cursor[0]->copy()->extend({ name: 'popselectCursor' })]
  hlset(hl_popselect_cursor)
  hi clear Cursor
  win_execute(filter_winid, 'syntax match popselectCursor / $/')
  blink_timer = timer_start(500, popselect#BlinkCursor, { repeat: -1 })
enddef

def RestoreCursor()
  set t_ve&
  hlset(hl_cursor)
enddef

export def BlinkCursor(timer: number)
  if winid ==# 0 || popup_list()->index(winid) ==# -1
    # ここに来るのはポップアップが意図せず残留したとき
    # または<C-c>などで強引にポップアップを閉じられたとき
    Close()
    return
  endif
  blink = !blink
  if blink
    hi clear popselectCursor
  else
    hlset(hl_popselect_cursor)
  endif
enddef

export def Icon(path: string, type: string = 'file'): string
  if type ==# 'dir'
    if path ==# '..'
      return g:popselect.icon_dirup
    elseif path->fnamemodify(':t') ==# '.git'
      return g:popselect.icon_dirgit
    else
      return g:popselect.icon_diropen
    endif
  elseif type ==# 'term'
    return g:popselect.icon_term
  endif
  try
    const icon = nerdfont#find(expand(path))
    if icon !=# ''
      return icon
    endif
  catch
    # nop
  endtry
  return g:popselect.icon_unknown
enddef
