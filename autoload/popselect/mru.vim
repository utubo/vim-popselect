vim9script

var mru = v:oldfiles->copy()

augroup popselect_mru
  au!
  au BufEnter * Update()
augroup END

def Update()
  const path = expand('%:p')
  const i = mru->index(path)
  if i !=# -1
    mru->remove(i)
  endif
  mru = [path] + mru
enddef

export def Popup(options: any = {})
  popselect#files#Popup(mru, { title: 'MRU' }->extend(options))
enddef

