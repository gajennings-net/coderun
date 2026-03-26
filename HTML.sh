# HTML "Template"

# MAKE Radio Buttons
s=
n=1
for i in ${!radio[@]}; do
	t=${radio[$i]}
	v=
	if [[ $i == $option ]]; then
		v=checked
	fi
	s+="<span title='$t'><input type='radio' name='option' $v value='$i'>$i</span>$EOL"
	if (( ! ( n % 8 ) )); then
		s+="<br>"
	fi
	(( n++ ))
done
RAD_OPTIONS=$s

# MAKE Checkboxes
s=
for i in ${!checkbox[@]}; do
	declare -n v=$i
	t=${checkbox[$i]}
	if [[ $v == on ]]; then
		v=checked
	fi
	s+="<span title='$t'><input type='checkbox' $v name='$i' />$i</span>$EOL"
done
BOX_OPTIONS=$s

# MAKE Select
s="<option none> </option>$EOL"
for o in ${select[@]}; do
	t=${o:4}
	v=
	if [[ $t == $type ]]; then
		v=selected
	fi
	s+="<option $v $o>$o</option>$EOL"
done
SEL_OPTIONS=$s

echo "<!DOCTYPE html>
<html lang='en'>
<head>
<title>$INDEX $VER</title>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
<link href="index.css" rel="stylesheet" type="text/css">
</head>
<body id=''>
<div><b><a href="">$INDEX</a> v$VER</b></div>
<form method='post' action='?'>
<textarea name='data'>$data</textarea>
$RAD_OPTIONS<br />
<input type='text' name='args' title='arguments to code' placeholder='arguments' value='$args' />
<br />
<select name='tmpfile' title='temporary language files'>
$SEL_OPTIONS
</select><br />
<button title='load temporary file for language previously used' name='button' value='load'>load</button><br />
<button title='load code example for selected language' name='button' value='new'>new</button><br />
<button title='save textarea' name=button value=save>save</button><input type='text' name='savfile' title='save file' value='' />
<br style='clear:both;' />
<button style='margin-left:0;' title='run the code for the selected language' name='button' value='runcode'>run</button>
$BOX_OPTIONS
</form>
<span id=message>$message</span>
<hr />
"

return

# END

# NOTES
