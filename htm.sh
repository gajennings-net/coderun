# HTM.SH - The HTML Data.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
HTM=1.12

EOL=$'\n'

# SEE ALSO QRY.SH*
# SEE ALSO BIN.SH

# FORM DATA 
# radio is match to BIN.SH and option 		# NOTEC
declare -A radio
declare -A checkbox
declare -a select
select=(tmp.*)

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

# CHECKBOXES: MAKE
function c_output {
	local c t s
	for c in ${!checkbox[@]}; do
		declare -n v=$c
		t=${checkbox[$c]}
		if [[ $v == on ]]; then
			declare -g $c=checked
		fi
		s+="<span title='$t'><input type='checkbox' $v name='$c' />$c</span>$EOL"
	done
	BOX_OPTIONS=$s
}

# RADIO: MAKE
function r_output {
	local r s t v n=1
	for r in ${!radio[@]}; do
		declare -n v=$r
		t=${radio[$r]}
		if [[ $r == $option ]]; then
			v=checked
		else
			v=""
		fi
		# TITLE, [CHECKED], VALUE=NAME, (NAME)
		s+="<span title='$t'><input type='radio' name='option' $v value='$r'>$r</span>$EOL"
		if (( ! ( n % 8 ) )); then
			s+="<br>"
		fi
		(( n++ ))
	done
	RAD_OPTIONS=$s
}

# SELECT: MAKE HTML [name] [none]
function s_output {
	local o t s v
	if [[ $2 ]]; then
		s+="<option none> </option>$EOL"
	fi
	for o in ${select[@]}; do
		t=${o:4}
		if [[ $t == $type ]]; then
			v=selected
		else
			v=""
		fi
		s+="<option $v $o>$o</option>$EOL"
	done
	SEL_OPTIONS=$s
}

# MODULE ENTRY
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
	s_output tmpfile none
	echo "<div><b><a href="">$INDEX</a> v$VER</b></div>
<form method='post' action='?'>
<textarea name='data'>$data</textarea>
$RAD_OPTIONS<br />
<input type='text' name='args' title='arguments to code' placeholder='arguments' value='$args' /><br />
<select name='tmpfile' title='temporary language files'>
$SEL_OPTIONS
</select><br />
<button title='load temporary file for language previously used' name='button' value='load'>load</button><br />
<button title='load code example for selected language' name='button' value='new'>new</button>
<br style='clear:both;' />
<button style='margin-left:0;' title='run the code for the selected language' name='button' value='runcode'>run</button>
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
