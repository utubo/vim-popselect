vim9script

export def Popup(files: list<string>, options: any = {})
  var items = []
  var seen = {}
  var root = get(options, 'root', '')
  for f in files
    if seen->has_key(f)
      continue
    elseif filereadable(expand(f))
      var extra = f->fnamemodify(':p:h')
      g:a = root
      g:b = extra
      if !!root && extra->stridx(root) ==# 0
        extra = '.' .. extra[len(root) :]
      endif
      add(items, {
        icon: popselect#Icon(f),
        label: fnamemodify(f, ':t'),
        extra: extra,
        target: f
      })
      seen[f] = 1
    endif
  endfor
  popselect#Popup(items, options)
enddef

