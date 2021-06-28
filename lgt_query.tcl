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
	flush $lgt::logtalk
	discard_to_ready
	# Log connected
	puts "Logtalk connected"
}

proc connect_to {loader} {
	# Open as file
	set lgt::logtalk [open "|$lgt::load_cmd" w+]
	# Load loader
	puts $lgt::logtalk "logtalk_load(\['$lgt::install_dir/loader.lgt', '$loader'\]), tkinter::go."
	flush $lgt::logtalk
	discard_to_ready
	# Log connected
	puts "Logtalk connected"
}

proc discard_to_ready {} {
	set line ""
	while {$line != "LOGTALK READY"} {
		gets $lgt::logtalk line
		# puts $line
	}
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
