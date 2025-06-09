vim9script

# Note: g:popselect is initialized in ../popselect.vim
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
    var extra = ''
    var icon = ''
    if m[2][2] =~# '[RF?]'
      icon = popselect#Icon('', 'term')
      name = term_getline(nr, '.')
        ->substitute('\s*[%#>$]\s*$', '', '')
    else
      icon = popselect#Icon(path)
      name = fnamemodify(name, ':t')
      path = bufname(nr)->fnamemodify(':p:h')->pathshorten()
      const seen = bufs->indexof((_, v) => v.label ==# name)
      if seen !=# -1
        extra = path
        bufs[seen].extra = bufs[seen].path->pathshorten()
      endif
    endif
    const current = m[2][0] ==# '%'
    add(bufs, {
      icon: icon,
      label: name,
      extra: extra,
      tag: nr,
      modified: m[2] =~# '+',
      path: path,
      selected: current,
    })
  endfor
  popselect#Popup(bufs, {
    title: 'Buffers',
    onselect: (item) => execute($'buffer {item.tag}'),
    predelete: (item) => Delete(item.tag),
  }->extend(options))
enddef
