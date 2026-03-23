# CFG.SH - Configuration Functions: JSN, INI, EOF.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
CFG=1.0

if [[ -z $BAS ]]; then
	. ./bas.sh
fi

declare -A jsn

# READ JSN Global - NOTEJ
function read_jsn {
	local l k v
	exec {fd}<$1
	while read -r -u$fd l; do
		if [[ $l =~ ^"# DATA" ]]; then
			break
		fi
	done
	while read -r -u$fd l; do
		if [[ $l == "" ]]; then
			continue
		fi
		if [[ $l == "}" && $in ]]; then
			break
		fi
		if [[ $l == "{" && !$in ]]; then
			in=1
			continue
		fi
		l=${l# *}; l=${l%,}
		k=${l%%:*}
		v=${l#*:}
#echoe "$k=$v"
		[ "$v" == true ] && v=1
		[ "$v" == false ] && v=0
		k=${k%\"}; k=${k#\"}
		v=${v:1}; v=${v:0: -1}
		v=$(dec "$v")
		v=$(hun "$v")
		jsn[$k]=$v
	done
	exec {fd}<&-
}

# WRITE JSN Global to FILE
function write_jsn {
	local k v
	exec {fd}>$1
	echo "# DATA" >&$fd
	echo "{" >&$fd
	for k in ${!jsn[@]}; do
		v=${jsn[$k]}
		v=$(enc "$v")
		k="\"$k\""
		if [[ ! $v =~ ^[0-9]+$ ]]; then
			v="\"$v\""
		fi
		echo "  $k:$v," >&$fd
	done
	echo "}" >&$fd
	echo "# END" >&$fd
	exec {fd}<&-
}

# SET JSN Global
#  example: "setting true this off value 10"
function set_jsn_ref {
	local i k v
	unset jsn
	declare -g -A jsn
	for a in $@; do
		declare -n v=$a
		jsn[$a]=$v
	done
}

# SHOW JSN Global
function dump_jsn {
	local k v
	echo "{" 
	for k in ${!jsn[@]}; do
		v=${jsn[$k]}
		k="  \"$k\""
		if [[ ! $v =~ ^[0-9]+$ ]]; then
			v="\"$v\""
		fi
		echo "  $k:$v,"
	done
	echo "}" 
}

# END

# TEST

if [[ ${BASH_ARGV[@]} =~ -j ]]; then
	read_jsn $0
	echo "${!jsn[@]}:${jsn[@]}"
	dump_jsn 
	write_jsn TEMP.JSON
	cat TEMP.JSON
	unlink TEMP.JSON
	exit
fi

return

# NOTES

The "JSN" data format is JSON but without arrays and "# DATA" and "# END" 
prefix and suffix lines - so as to be read from a code source file. Handles 
backslash escapes \", \n, \t, etc.; and (on read) basic HTML entities &lt, 
&gt, &amp. The values "true" and "false" (without quotes) are converted to 
1 and 0 on read, but the opposite does not hold.

There is no error handling - ill-formated source leaves data in an unknown 
state.
