vim9script

# Note: g:popselect is initialized in ../popslect.vim
import '../popselect.vim'

export def Popup(options: any = {})
  var bufs = []
  var labels = []
  const ls_result = execute('ls')->split("\n")
  for ls in ls_result
    const m = ls->matchlist('^ *\([0-9]\+\) \([^"]*\)"\(.*\)" [^0-9]\+ [0-9]\+')
    if m->empty()
      continue
    endif
    const nr = str2nr(m[1])
    var name = m[3]
    var path = ''
    var icon = ''
    if m[2][2] =~# '[RF?]'
      icon = g:popselect.icon_term
      name = term_getline(nr, '.')
        ->substitute('\s*[%#>$]\s*$', '', '')
    else
      path = bufname(nr)->fnamemodify(':p')
      icon = popselect#NerdFont(path)
      name = fnamemodify(name, ':t')
    endif
    const current = m[2][0] ==# '%'
    add(bufs, {
      icon: icon,
      label: name,
      extra: path,
      tag: nr,
      selected: current
    })
  endfor
  popselect#Popup(bufs, {
    title: 'Buffers',
    onselect: (item) => execute($'buffer {item.tag}'),
    ondelete: (item) => execute($'bdelete! {item.tag}'),
  }->extend(options))
enddef
