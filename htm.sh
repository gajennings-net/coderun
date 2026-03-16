# HTM.SH - The HTML Data.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
HTM=1.0

# SEE ALSO QRY.SH*
# SEE ALSO BIN.SH

# FORM DATA 
# radio is match to BIN.SH and option 		# NOTEC
declare -A radio
declare -A checkbox

# CHECKBOXES
cfg_read htm.sh

# BIN to RADIOs
function bin_radio {
	declare -n r=radio
	for a in ${bins[@]}; do
		declare -n b=$a
		r[$a]=${b[desc]}
	done
}

# CHECKBOXES: SET
function c_checked {
	local c
	for c in ${!checkbox[@]}; do
		declare -n v=$c
		if [[ $v == on ]]; then
			declare -g $c=checked
		fi
	done
}

# CHECKBOXES: MAKE
function c_output {
	local c t s
	for c in ${!checkbox[@]}; do
		declare -n v=$c
		t=${checkbox[$c]}
		if [[ $v == on ]]; then
			declare -g $c=checked
		fi
		s+="<span title='$t'><input type='checkbox' $v name='$c' />$c</span>"
	done
	BOX_OPTIONS=$s
}

# RADIO: OPTION
function r_output {
	local r t s
	for r in ${!radio[@]}; do
		declare -n v=$r
		t=${radio[$r]}
		if [[ $r == $option ]]; then
			declare v=checked
		else
			declare v=""
		fi
		# TITLE, [CHECKED], VALUE=NAME, (NAME)
		s+="<span title='$t'><input type='radio' name='option' $v value='$r'>$r</span>"
	done
	RAD_OPTIONS=$s
}

htm() {
	case $1 in
	HEAD)
	echo "<!DOCTYPE html>
<html lang='en'>
<head>
<title>$INDEX $VER</title>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<link href="index.css" rel="stylesheet" type="text/css">
</head>
<body id=''>
"
	;;
	FORM)
	c_output
	r_output
	echo "<div style='float:left'><b><a href="">$INDEX</a> v$VER</b></div>
<form method='post' action='?'>
<input id='a' type='text' name='args' title='code' value='$args' />arguments
<br>
<textarea name='data'>$data</textarea>
$RAD_OPTIONS
<br style='clear:both;' />
<button title='run the code' name='button' value='runcode'>run</button>
$BOX_OPTIONS
</form>
<span id=message>$message</span>
<hr />
"
	;;
	esac
}

return

# END

# NOTES

# NOTEC

The "matching" of radio (button) data and the BINs data should be done via 
the CONFIG MAPPING MODULE (yet to be designed).

# NOTED

The chackbox array is to be created by this via code in CFG. (And then the 
code is going to be rewritten.)

# DATA
[checkbox]
diag "enable diagnostics"
raw "run code only"
text "result into textarea"
below "output below form"
html "output is HTML"
only "only display output"
clean "clean temp files"
# END
