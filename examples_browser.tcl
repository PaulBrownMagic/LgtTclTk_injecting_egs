package require Tk

wm title . "Logtalk Examples Browser"

source "menu.tcl"

grid [ttk::frame .script -padding "3 3 12 12"] -column 0 -row 0 -sticky wnes
grid [ttk::frame .interact -padding "3 3 12 12"] -column 1 -row 0 -sticky wnes
grid [ttk::frame .statusbar -relief sunken -height 64 -padding "3"] -column 0 -row 1 -columnspan 2 -sticky wes
grid columnconfigure	. 0 -weight 1
grid columnconfigure	. 1 -weight 1
grid rowconfigure		. 0 -weight 1

# Status Bar
grid [ttk::label .statusbar.status_lbl -text "Status:"] -column 0 -row 0 -sticky ws
grid [ttk::label .statusbar.status_msg -textvariable status] -column 1 -row 0 -sticky wes

# Script file
grid [ttk::label .script.heading -font TkHeadingFont -text "SCRIPT.txt"] -column 0 -row 0 -sticky w
grid [tk::text .script.contents -height 30] -column 0 -row 1 -sticky wnes

# Interaction
grid [ttk::label .interact.heading -font TkHeadingFont -text "Query"] -column 0 -row 0 -sticky w
grid [ttk::entry .interact.query_entry -textvariable user_query -state disabled] -column 0 -row 1 -sticky we
grid [ttk::button .interact.query_btn -text "Query" -command query -state disabled] -column 1 -row 1
grid [tk::text .interact.results -height 28] -column 0 -row 2 -columnspan 2 -sticky wnes
grid columnconfigure	.interact 0 -weight 4
grid columnconfigure	.interact 1 -weight 1


set ::status "Disconnected"
wm protocol . WM_DELETE_WINDOW on_close

proc on_close {} {
	# When closing the window disconnect Logtalk, then destroy the window
	if { $lgt::logtalk != 0 } {
		lgt::disconnect
	}
	set ::status "disconnected"
	destroy .
}

proc enable_query {} {
	.interact.query_entry configure -state normal
	.interact.query_btn configure -state normal
	focus .interact.query_entry
}
proc disable_query {} {
	.interact.query_entry configure -state disabled
	.interact.query_btn configure -state disabled
}

proc display_script_file {dir} {
	set script_file [open "$dir/SCRIPT.txt"]
	set ::script_text [read $script_file]
	close $script_file
	clear_script_file
	.script.contents insert 1.0 $::script_text
}

proc clear_script_file {} {
	.script.contents delete 1.0 end
	.interact.results delete 1.0 end
	set ::user_query ""
}

proc query {} {
	set ::status "Querying"
	.interact.results delete 1.0 end
	set query [string trimright $::user_query "."]
	set resp [lgt::query $query]
	switch [dict get $resp status] {
		"success" { show_results [dict get $resp unifications] }
		"error" { .interact.results insert 1.0 "Error -> [dict get $resp error]" }
		"fail" { .interact.results insert 1.0 "fail." }
	}
	set ::status "Connected"
}

proc show_results {unifications} {
	set line 1.0
	dict for {k v} $unifications {
		.interact.results insert $line "$k = $v,\n"
		set line [expr {$line + 1.0} ]
	}
	.interact.results insert $line "true."
}
