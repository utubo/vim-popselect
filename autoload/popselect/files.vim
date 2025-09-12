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
const ping_timeout = 100
var bad_servers = []
var good_servers = []
var server_regex = '^//\([^/]\+\)'
if has('win32')
  server_regex = server_regex->substitute('/', '\\\\', 'g')
endif

def TestServer(path: string): bool
  const s = path->matchlist(server_regex)->get(1, '')
  if !s
    return true
  elseif good_servers->index(s) !=# -1
    return true
  elseif bad_servers->index(s) ==# -1
    var r = { status: -1 }
    const j = job_start($'ping -n 1 -t {ping_timeout} {s}', {
      exit_cb: (_, st) => {
        r.status = st
      }
    })
    while job_status(j) ==# 'run'
      sleep 10m
    endwhile
    if !r.status
      good_servers->add(s)
      return true
    endif
    bad_servers->add(s)
    echow $'Connect faild: {s}'
  endif
  return false
enddef

export def GetFiles(): list<any>
  var items = []
  var pagelimit = opt.maxheight
  const ign = get(g:popselect, 'ignore_regexp', '') # TODO: pending...
  while index < src->len()
    const f = src[index]
    index += 1
    try
      if !!ign && f->match(ign) !=# -1
        continue
      endif
      if !TestServer(f)
        continue
      endif

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
  bad_servers = []
  good_servers = []
  index = 0
  seen = {}
  src = files
  var first = GetFiles()
  popselect_id = popselect#Popup(first, options)
  timer_start(interval_ms, AsyncListFiles)
enddef

