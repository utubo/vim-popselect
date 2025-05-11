vim9script

export def Popup(files: list<string>, options: any = {})
	var items = []
	var seen = {}
	for f in files
		if seen->has_key(f)
			continue
		elseif filereadable(expand(f))
			add(items, {
				icon: popselect#NerdFont(f),
				label: fnamemodify(f, ':t'),
				extra: f->fnamemodify(':p'),
				target: f
			})
			seen[f] = 1
		endif
	endfor
	popselect#Popup(items, options)
enddef

