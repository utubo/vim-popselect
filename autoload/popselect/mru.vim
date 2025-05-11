vim9script

export def Popup(options: any = {})
	popselect#files#Popup(v:oldfiles, { title: 'MRU' }->extend(options))
enddef

