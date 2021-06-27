:- initialization((
	logtalk_load([
		dictionaries(loader),
		nested_dictionaries(loader),
		term_io(loader),
		json(loader)
	]),
	logtalk_load([
		tkinter
	],
	[
		optimize(on)
	])
)).
