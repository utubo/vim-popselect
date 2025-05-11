vim9script

export def Popup(path: string = '', options: any = {})
  var items = []
  const fullpath = path ==# '' ? expand('%:p:h') : path
  if fullpath->fnamemodify(':h') !=# fullpath
    add(items, {
      icon: popselect#Icon('..', 'dir'),
      label: '..',
      dir: fullpath->fnamemodify(':h'),
      isdir: true,
    })
  endif
  const files = readdirex(fullpath, '1', { sort: 'collate' })
  for f in files
    const isdir = f.type ==# 'dir' || f.type ==# 'linkd'
    var item = {
      icon: popselect#Icon(f.name, isdir ? 'dir' : 'file'),
      label: f.name,
      isdir: isdir,
    }
    item[isdir ? 'dir' : 'target'] = $'{fullpath}/{f.name}'
    add(items, item)
  endfor
  popselect#Popup(items, {
    title: popselect#Icon(fullpath, 'dir') .. fnamemodify(fullpath, ':t:r'),
    filter_focused: !path ? '' : 'keep',
    precomplete: (item): bool => {
      if item.isdir
        popselect#Close()
        Popup(item.dir, options)
        return true
      else
        return false
      endif
    }
  }->extend(options))
enddef

