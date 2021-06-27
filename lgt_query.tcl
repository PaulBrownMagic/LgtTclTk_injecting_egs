package require json

namespace eval ::lgt {

variable logtalk 0
variable install_dir [pwd]
variable load_cmd "logtalk"

proc connect {} {
	# Open as file
	set lgt::logtalk [open "|$lgt::load_cmd" w+]
	# Load loader
	puts $lgt::logtalk "logtalk_load('$lgt::install_dir/loader.lgt'), tkinter::go."
	#puts $lgt::logtalk "{loader}, tkinter::go."
	flush $lgt::logtalk
	set line ""
	while {$line != "'READY'"} {
		gets $lgt::logtalk line
		#puts $line
	}
	# Log connected
	puts "Logtalk connected"
}

proc connect_to {loader} {
	# Open as file
	set lgt::logtalk [open "|$lgt::load_cmd" w+]
	# Load loader
	puts $lgt::logtalk "logtalk_load('$lgt::install_dir/loader.lgt'), logtalk_load('$loader'), tkinter::go."
	#puts $lgt::logtalk "{loader}, tkinter::go."
	flush $lgt::logtalk
	set line ""
	while {$line != "'READY'"} {
		gets $lgt::logtalk line
		#puts $line
	}
	# Log connected
	puts "Logtalk connected"

}

proc disconnect {} {
	puts $lgt::logtalk "halt."
	flush $lgt::logtalk
	# catch to ignore unflushed output
	catch {close $lgt::logtalk}
	set lgt::logtalk 0
	# Log disconnected
	puts "Logtalk disconnected"
}

proc query {query} {
	# query
	puts $lgt::logtalk "$query."
	flush $lgt::logtalk

	# response
	gets $lgt::logtalk user_output
	set ans [json::json2dict $user_output]

	# respond
	return $ans
}

}
