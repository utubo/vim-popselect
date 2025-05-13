vim9script

# Note: g:popselect is initialized in ../popslect.vim
import '../popselect.vim'

def Delete(nr: number): bool
  try
    execute $'confirm bdelete {nr}'
  catch
    return true
  endtry
  return false
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
    predelete: (item) => Delete(item.tag),
  }->extend(options))
enddef
