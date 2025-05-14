vim9script

export def Popup(files: list<string>, options: any = {})
  var items = []
  var seen = {}
  var root = get(options, 'root', '')
  for f in files
    const full = f->expand()->fnamemodify(':p')
    if seen->has_key(full)
      continue
    elseif filereadable(full)
      var extra = full->fnamemodify(':h')
      if !!root && extra->stridx(root) ==# 0
        extra = '.' .. extra[len(root) :]
      endif
      add(items, {
        icon: popselect#Icon(f),
        label: fnamemodify(f, ':t'),
        extra: extra,
        target: f
      })
      seen[full] = 1
    endif
  endfor
  popselect#Popup(items, options)
enddef

