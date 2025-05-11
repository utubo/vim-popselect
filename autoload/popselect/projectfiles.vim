vim9script

# Note: g:popselect is initialized in ../popslect.vim
import '../popselect.vim'

def GetProjectFilesRecuse(path: string, nest: number, limit: number): list<string>
  var result = []
  var children = []
  var l = limit
  const files = readdirex(path, '1', { sort: 'collate' })
  for f in files
    l -= 1
    if l <= 0
      break
    endif
    const fullpath = $'{path}/{f.name}'
    if f.type ==# 'dir' || f.type ==# 'linkd'
      if index(g:popselect.projectfiles_ignore_dirs, f.name) !=# -1
        # nop
      elseif 0 < nest
        children += GetProjectFilesRecuse(fullpath, nest - 1, l)
      endif
    else
      add(result, fullpath)
    endif
  endfor
  return result + children
enddef

export def GetProjectFiles(): list<string>
  var found_root = false
  var path = expand('%:p:h')
  var depth = 0
  while true
    depth += 1
    for a in g:popselect.projectfiles_root_anchor
      if isdirectory($'{path}/{a}') || filereadable($'{path}/{a}')
        found_root = true
        break
      endif
    endfor
    if found_root
      break
    endif
    const parent = fnamemodify(path, ':h')
    if path ==# parent
      break
    else
      path = parent
    endif
  endwhile
  if !found_root
    path = expand('%:p:h')
    depth = 0
  endif
  return GetProjectFilesRecuse(
    path,
    g:popselect.projectfiles_depth + depth,
    g:popselect.projectfiles_limit
  )
enddef

export def Popup(options: any = {})
  var items = GetProjectFiles()
  popselect#files#Popup(
    items,
    { title: 'Project files', filter_focused: true }->extend(options),
  )
enddef

export def PopupMruAndProjectFiles(options: any = {})
  var items = v:oldfiles + GetProjectFiles()
  popselect#files#Popup(
    items,
    { title: 'MRU + Project files', filter_focused: true }->extend(options),
  )
enddef

