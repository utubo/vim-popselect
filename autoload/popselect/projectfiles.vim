vim9script

# Note: g:popselect is initialized in ../popslect.vim
import '../popselect.vim'

var anchor_regex = ''
var ignore_regex = ''
var root = ''

def GetProjectFilesRecuse(path: string, nest: number, limit: number): list<string>
  var result = []
  var children = []
  var p = path->substitute('[/\\]$', '', '')
  var l = limit
  const files = readdirex(path, '1', { sort: 'collate' })
  for f in files
    try
      l -= 1
      if l <= 0
        break
      endif
      const fullpath = $'{p}/{f.name}'
      if f.type ==# 'dir' || f.type ==# 'linkd'
        if 0 < nest && match(f.name, ignore_regex) ==# -1
          var c = GetProjectFilesRecuse(fullpath, nest - 1, l)
          children += c
          l -= c->len()
        endif
      else
        add(result, fullpath)
      endif
    catch
      silent! echoe v:errors
    endtry
  endfor
  return result + children
enddef

def GetProjectRoot(): string
  var anchors = []
  for a in g:popselect.projectfiles_root_anchor
    anchors->add(glob2regpat(a))
  endfor
  anchor_regex = anchors->join('\|')
  var found_root = false
  var depth = g:popselect.projectfiles_depth
  var path = expand('%:p:h')
  while true
    depth -= 1
    if depth < 0
        break
    endif
    const files = readdirex(path, '1', { sort: 'collate' })
    for f in files
      if match(f.name, anchor_regex) !=# -1
        return path
      endif
    endfor
    const parent = fnamemodify(path, ':h')
    if path ==# parent
      break
    else
      path = parent
    endif
  endwhile
  return expand('%:p:h')
enddef

export def GetProjectFiles(): list<string>
  var ignores = []
  for i in g:popselect.projectfiles_ignore_dirs
    ignores->add(glob2regpat(i))
  endfor
  ignore_regex = ignores->join('\|')
  root = GetProjectRoot()
  return GetProjectFilesRecuse(
    root,
    g:popselect.projectfiles_depth,
    g:popselect.limit
  )
enddef

export def Popup(options: any = {})
  var items = GetProjectFiles()
  popselect#files#Popup(items, {
    title: 'Project files',
    root: root,
  }->extend(options))
enddef

export def PopupWithMRU(options: any = {})
  var items = GetProjectFiles() + popselect#mru#GetMRU()
  popselect#files#Popup(items, {
    title: 'Project files + MRU',
    root: root,
  }->extend(options))
enddef

