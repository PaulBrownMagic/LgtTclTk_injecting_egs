source "lgt_query.tcl"

# Menu
option add *Menu.tearOff 0
menu .mbar
. configure -menu .mbar

menu .mbar.lgt
.mbar add cascade -label "Logtalk Examples" -menu .mbar.lgt -underline 0

.mbar.lgt add command -label "Open Example" -command lgt_select
.mbar.lgt add separator
# How to disable these when not relevant?
.mbar.lgt add command -label Connect -command lgt_connect -state disabled
.mbar.lgt add command -label Disconnect -command lgt_disconnect -state disabled
.mbar.lgt add command -label Exit -command exit

set ::dirname 0
set ::examples_dir [pwd]

proc get_examples_dir {} {
	lgt::connect
	set resp [lgt::query {logtalk::expand_library_path(examples, Path)}]
	lgt::disconnect
	switch [dict get $resp status] {
		"success" { set ::examples_dir [dict get [dict get $resp unifications] Path] }
		"error" { set ::status "Error -> Can't find Logtalk Examples" }
		"fail" { set ::status "Error -> Can't find Logtalk Examples" }
	}
}
get_examples_dir

proc lgt_select {} {
	# Replace test for connection to disconnect with query to lgt::
	# Might be able to make $::dirname local to this proc then
	if {$::dirname != 0} {
		lgt_disconnect
	}

	cd $::examples_dir
	set ::dirname [tk_chooseDirectory]

	if {$::dirname == ""} {
		set ::dirname 0
	} else {
		cd $::dirname
		puts $::dirname
		set ::status "Working directory: $::dirname"
		.mbar.lgt entryconfigure 2 -state normal
		.mbar.lgt entryconfigure 3 -state disabled
		if {[tk_messageBox -type yesno -icon question -message "Connect to Logtalk?" -parent .]} {
			lgt_connect
		}
	}
}

proc lgt_connect {} {
	puts "Logtalk Connect"
	lgt::connect_to "$::dirname/loader.lgt"
	.mbar.lgt entryconfigure 2 -state disabled
	.mbar.lgt entryconfigure 3 -state normal
	set ::status "Connected to $::dirname"
	display_script_file $::dirname
	enable_query
}


proc lgt_disconnect {} {
	puts "Logtalk Disconnect"
	lgt::disconnect
	.mbar.lgt entryconfigure 2 -state normal
	.mbar.lgt entryconfigure 3 -state disabled
	clear_script_file
	disable_query
	set ::dirname 0
	set ::status "Disconnected"
}

