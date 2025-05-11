vim9script

# Note: g:popselect is initialized in ../popslect.vim
import '../popselect.vim'

export def Popup(options: any = {})
  var items = []
  const current = tabpagenr()
  for tab in range(1, tabpagenr('$'))
    var label = ''
    var bufs = tabpagebuflist(tab)
    const win = tabpagewinnr(tab) - 1
    bufs = remove(bufs, win, win) + bufs
    var names = []
    var i = -1
    for b in bufs
      i += 1
      var name = bufname(b)
      if !name
        name = '[No Name]'
      elseif getbufvar(b, '&buftype') ==# 'terminal'
        name = g:popselect.icon_term .. term_getline(b, '.')->trim()
      else
        name = name->pathshorten()
      endif
      const l = len(name)
      if names->index(name) ==# -1
        names += [name]
      endif
    endfor
    label ..= names->join(', ')
    add(items, { label: label, tag: tab, selected: tab ==# current })
  endfor
  popselect#Popup(items, {
    title: 'Tab pages',
    onselect: (item) => execute($'tabnext {item.index}'),
    ondelete: (item) => execute($'tabclose! {item.index}'),
    onkey_t: () => popselect#Move('j'),
    onkey_T: () => popselect#Move('k'),
  }->extend(options))
enddef

