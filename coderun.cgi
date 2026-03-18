#!/bin/bash 
# This is Code Runner, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
VER=1.0
PROG=coderun.cgi
if [[ ${BASH_SOURCE[@]} != $PROG ]]; then
	Ef=ERR.log
	exec 2>$Ef
fi

. ./diag.sh	# 0
. ./srv.sh	# 1
. ./qry.sh	# 2
. ./bin.sh
. ./bas.sh
. ./cfg.sh
. ./htm.sh

if [[ $diag ]]; then
	diag -l 1
	diag -t 1
fi

header
htm 'HEAD'

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

# WHICH BIN
bin_option
if [[ -z $button ]]; then
	diag "bin: $bin"
fi
bin_radio

# EXEC
if [[ $button == runcode && $data ]]; then
	diag "$bin $tmp $args"
	if [[ $env ]]; then
		export "$env"
	fi
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
	# EXEC
	res=$($bin $tmp $args 2>err.txt)
	if [[ $clean ]]; then
		unlink $tmp
	fi
	if [[ -f err.txt ]]; then
		res+=$(< err.txt)
		unlink err.txt
	fi
	if [[ $comp ]]; then
		if [[ -z $res ]]; then
			res=$(./a.exe)
			unlink a.exe
		fi
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
	if [[ $clean ]]; then
		rm $Ef
	fi
fi

exit

# END

# NOTES

Oh, I should have called this project - The Executioner. For that's all it is. 
You add the name of a binary in the data, and then form will be passed to that 
binary. That is all.

P.S. I can place commentary in the code like this because Bash does not see 
them. (Your editor might squawk, but that's not my problem as I use one that 
just highlights them in a funny way...

# NOTET

Probably should make the temporary file(s) in TEMPDIR... 

# NOTED

A Module Connection that should not exist; see README.
