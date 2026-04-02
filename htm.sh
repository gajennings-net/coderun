# HTM.SH - The HTML Data.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
HTM=1.12

EOL=$'\n'

# FORM DATA 
declare -A radio
declare -A checkbox
declare -a select
select=($TEMP/tmp.*)

checkbox[diag]="enable diagnostics"
checkbox[text]="result into textarea"
checkbox[below]="output below form"
checkbox[html]="output is HTML"
checkbox[only]="only display output"
checkbox[clean]="clean temp files"
checkbox[debug]="the collossal debugger"

# BINs to RADIOs
function bin_radio {
	declare -n r=radio
	for a in ${bins[@]}; do
		declare -n b=$a
		r[$a]=${b[desc]}
	done
}

return

# END

# NOTES

