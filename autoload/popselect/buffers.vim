vim9script

# Note: g:popselect is initialized in ../popslect.vim
import '../popselect.vim'

def Confirm(item: any): bool
  if !item.modified
    return false
  endif
  const name = bufname(item.tag)
  const c = popselect#Confirm([
    $'Save changes to "{name ?? 'Untitled'}"?',
    '(Y)es, (N)o, (C)ancel',
  ])
  if c ==# 'n'
    return false
  elseif c ==# 'y'
    if name ==# ''
      save Untitled
    else
      write
    endif
    return false
  else
    return true
  endif
enddef

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
      icon = popselect#Icon('', 'term')
      name = term_getline(nr, '.')
        ->substitute('\s*[%#>$]\s*$', '', '')
    else
      path = bufname(nr)->fnamemodify(':p')
      icon = popselect#Icon(path)
      name = fnamemodify(name, ':t')
    endif
    const current = m[2][0] ==# '%'
    add(bufs, {
      icon: icon,
      label: name,
      extra: path,
      tag: nr,
      modified: m[2] =~# '+',
      selected: current,
    })
  endfor
  popselect#Popup(bufs, {
    title: 'Buffers',
    onselect: (item) => execute($'buffer {item.tag}'),
    predelete: (item) => Confirm(item),
    ondelete: (item) => execute($'bdelete! {item.tag}'),
  }->extend(options))
enddef
