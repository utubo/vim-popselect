vim9script

export def Popup()
	popselect#files#Popup(v:oldfiles, { title: 'MRU' })
enddef

