#!/bin/bash 
# This is Code Runner, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
VER=2.2
PROG=coderun.cgi
if [[ ${BASH_SOURCE[@]} != $PROG ]]; then
	Ef=ERR.log
	exec 2>$Ef
fi

. ./diag.sh
src=(srv qry bin bas cfg htm dat)		# NOTESRC
for s in ${src[@]}; do
	. ./$s.sh
done

if [[ $diag ]]; then
	diag -l 1
	diag -t 1
fi

header

# FIRST LOAD
if [[ -z $button ]]; then
	if [[ -f form.jsn ]]; then
		read_jsn form.jsn
		for a in ${!jsn[@]}; do
			v=${jsn[$a]}
			declare $a="$v"
		done
		unset a
	fi
fi

# NEW
if [[ $button == new ]]; then
	read_data dat.sh
	data=${code[$option]}
fi

# LOAD
if [[ $button == load ]]; then
	data=$(< $tmpfile)
	option=${tmpfile:4}
fi

# WHICH BIN
bin_read
bin_option
bin_radio

# EXEC
if [[ $button == runcode && $data ]]; then
	if [[ $env ]]; then
		export "$env"
	fi
	tmp=tmp.$type
	if [[ $pre ]]; then
		echo "$pre" > $tmp 		# NOTET
		echo "$data" >> $tmp
	else
		echo "$data" > $tmp
	fi
	if [[ $raw ]]; then
		$bin $tmp $args
		exit
	fi
	if [[ $comp ]]; then
		diag "$bin, $tmp"
		res=$($bin $tmp 2>err.txt)
	else
		diag "$bin, $tmp [ $args ]"
		res=$($bin $tmp $args 2>err.txt)
	fi
	if [[ $clean ]]; then
		unlink $tmp
	fi
	if [[ -s err.txt ]]; then
		res+=$(< err.txt)
	else
		if [[ $comp ]]; then
			if [[ -z $res ]]; then
				: ${exe:=a.exe}
				diag "./$exe [ $args ]"
				res=$(./$exe $args)
				unlink ./$exe
			fi
		fi
	fi
	if [[ -f err.txt ]]; then
		unlink err.txt
	fi

	# EARLY OUTPUT
	if [[ $only ]]; then
		res=$(hen "$res")
		echo "$res"
		exit
	fi
fi

# HTML
if [[ $data ]]; then
	data=$(hen "$data")
	if [[ ${data:-1} != $'\n' ]]; then
		 data+=$'\n'
	fi
fi

read_data htm.sh			# see HTM.SH NOTEG
htm 'HEAD'
htm 'FORM'
echo "<pre>"

# OUPUT
if [[ $res ]]; then
	res=$(hen "$res")
	echo "$res"
fi

# SAVE FORM DATA
if [[ $button == runcode ]]; then 
	s=${Qa[@]}			# NOTED
	s=${s//button/}			# 1
	set_jsn_ref "$s"
	write_jsn form.jsn
fi
# 1. A non-connect connect - or, a DRAT...

# DEBUG SHIT
if [[ $debug ]]; then
	diag "$POST_STRING"
fi

if [[ -f $Ef ]]; then
	if [[ -s $Ef ]]; then
		cat $Ef
	fi
	rm $Ef
fi

exit

# END

# NOTES

Oh, I should have called this project - The Executioner. For that's all it is: 
You add the name of a binary in BIN.SH, and the form data will be passed to 
that binary as a temporary file. That is all.

P.S. I can place commentary in the code like this because Bash does not see 
them. (Your editor might squawk, but that's not my problem as I use one that 
just highlights them in a funny way...)

P.P.S. I use Cygwin/Windows and Visual Studio Code. It works.

# NOTESRC

I so dislike maintaining code... Code should maintain itself. Though very far 
from this goal overall, handling a bunch of includes is a pretty good (though 
small) example. (Ideally, includes are by a glob...) Oh [crap], there is an 
order to the includes - well, for BAS.SH...

# NOTET

Probably should make the temporary file(s) in TEMPDIR? Naaah. (Kinda messes 
with IDEs though.)

# NOTED

A Module Connection that should not exist...
