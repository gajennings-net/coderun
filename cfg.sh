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
		if [[ $l == "# DATA" ]]; then
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

# READ CFG FILE into Globals
function read_cfg {
	local k v
	while read -r k v; do
		if [[ ${k:0:1} == ";" ]]; then
			continue
		fi
		declare -g $k=$v
	done <$1
}

# READ CFG FILE into a named array (based on filename)
function read_cfga {
	local k v
	declare -g -A ${1%.*}
	local -n cfg=${1%.*}
	while read -r k v; do
		if [[ ${k:0:1} == ";" ]]; then
			continue
		fi
		cfg[$k]=$v
	done <$1
}

# LOAD CFG DATA of file to Global; SEE ALSO BIN.SH
function cfg_read {
	local l b k v
	exec {fd}<$1
	while read -r -u$fd l; do
		if [[ $l == "# DATA" ]]; then
			break
		fi
	done
	while read -r -u$fd l; do
		if [[ $l == "" ]]; then
			continue
		fi
		if [[ $l == "# END" ]]; then
			break
		fi
		if [[ "${l:0:1}" == "[" ]]; then
			b=${l:1:-1}
			declare -g -A $b
			continue
		fi
		k=${l%% *}; v=${l#* }; v=${v%\"}; v=${v#\"}
		declare -g -n r=$b
		r[$k]="$v"
	done
	exec {fd}<&-
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
fi

if [[ ${BASH_ARGV[@]} =~ -c ]]; then
#	declare -A coderun		# this is nice but not required
	read_cfga coderun.cfg
	for i in "${!coderun[@]}"; do
		echo "$i = ${coderun[$i]}"
	done
fi

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	exit
fi

return

# NOTES

All the "file readers" are unforgiving (no error handlers) and expect proper 
formatting: no leading spaces; no tabs; no trailing comments; etc. Blank lines 
are generally okay. Only the CFG fomrat used commented lines. This is so that 
Bash Parameter Expansion is all that is needed to parse the data.

CFG format (read_cfg)

   l="foo bar"
   k=${l%% *}           # delete SPACE and beyond end, 'foo'
   v=${l#* }            # delete up to and SPACE, 'bar'
   v=${v%\"}; v=${v#\"} # remove any "quoted"

INI format (read_ini)

   l="foo=bar"
   ${l%%=*}		# 'foo'
   ${l#*=}              # 'bar'
   k=${k%% *}           # removes (any) trail spaces
   v=${v#* }            # " lead "

This might be an interesting way to do things:

   while read -r a b c d; do
      echo "$a, $b, $c, $d"
   done <FILE.INI
...

# NOTEJ

The "JSN" data format is JSON but without arrays and "# DATA" and "# END" 
prefix and suffix lines - so as to be read from a code source file. Handles 
backslash escapes \", \n, \t, etc.; and (on read) basic HTML entities &lt, 
&gt, &amp. The values "true" and "false" (without quotes) are converted to 
1 and 0 on read, but the opposite does not hold.

There is no error handling - ill-formated source leaves data in an unknown 
state.

# DATA
{
  "bin":"php",
  "tmp":"php.tmp",
  "value":10
}
# END
