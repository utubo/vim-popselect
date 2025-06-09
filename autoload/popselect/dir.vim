vim9script

# Note: g:popselect is initialized in ../popslect.vim
import '../popselect.vim'

def PreComplete(item: any, options: any): bool
  if item.isdir
    popselect#Close()
    Popup(item.dir, options
      ->copy()
      ->extend({ filter_focused: 'keep' })
    )
    return true
  else
    return false
  endif
enddef

export def Popup(path: string = '', options: any = {})
  var items = []
  var fullpath = expand(path) ?? expand('%:p:h')
  const dlm = has('win32') ? '\' : '/'
  fullpath = fullpath->substitute('[\\/]*$', dlm, '')
  const tailess = fullpath[0 : -2]
  if filereadable(fullpath)
    fullpath = fnamemodify(fullpath, ':h')
  endif
  if fullpath->fnamemodify(':h') !=# fullpath
    add(items, {
      icon: popselect#Icon('..', 'dir'),
      label: '..',
      dir: tailess->fnamemodify(':h'),
      isdir: true,
    })
  endif
  const files = readdirex(fullpath, '1', { sort: 'collate' })
  var l = g:popselect.limit
  for f in files
    const isdir = f.type ==# 'dir' || f.type ==# 'linkd'
    var item = {
      icon: popselect#Icon(f.name, isdir ? 'dir' : 'file'),
      label: f.name,
      isdir: isdir,
    }
    item[isdir ? 'dir' : 'target'] = $'{fullpath}{f.name}'
    add(items, item)
    l -= 1
    if l < 0
      break
    endif
  endfor
  popselect#Popup(items, {
    title: popselect#Icon(fullpath, 'dir') .. (fnamemodify(tailess, ':t:r') ?? fullpath),
    precomplete: (item) => PreComplete(item, options),
  }->extend(options))
enddef

