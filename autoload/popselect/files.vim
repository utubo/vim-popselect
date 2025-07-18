vim9script

# Note: g:popselect is initialized in ../popselect.vim
import '../popselect.vim'

var popselect_id = 0
var index = 0
var src = []
var opt = {}
var seen = {}
var root = ''
var limit = 0
const interval_ms = 10

export def GetFiles(): list<any>
  var items = []
  var pagelimit = opt.maxheight
  while index < src->len()
    const f = src[index]
    index += 1
    try
      const full = f->expand()->fnamemodify(':p')
      if seen->has_key(full)
        continue
      elseif filereadable(full)
        var extra = full->fnamemodify(':h')
        if !!root && extra->stridx(root) ==# 0
          extra = '.' .. extra[len(root) :]
          extra = extra ==# '.' ? '' : extra
        endif
        add(items, {
          icon: popselect#Icon(f),
          label: fnamemodify(f, ':t'),
          extra: extra,
          target: f
        })
        seen[full] = 1
        pagelimit -= 1
        if pagelimit < 0
          break
        endif
        limit -= 1
        if limit < 0
          break
        endif
      endif
    catch
      silent! echoe v:errors
    endtry
  endwhile
  return items
enddef

def AsyncListFiles(timer: number)
  if popselect_id !=# popselect#Id()
    return
  endif
  var items = GetFiles()
  if !!items
    popselect#Add(items)
    timer_start(interval_ms, AsyncListFiles)
  endif
enddef

export def Popup(files: list<string>, options: any = {})
  # setup options
  opt = g:popselect->copy()->extend(options)
  limit = opt.limit
  root = get(opt, 'root', '')
  if root ==# root->fnamemodify(':p')
    root = ''
  endif
  # first popup
  index = 0
  seen = {}
  src = files
  var first = GetFiles()
  popselect_id = popselect#Popup(first, options)
  timer_start(interval_ms, AsyncListFiles)
enddef

