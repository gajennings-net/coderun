# DAT.SH - Configuration Functions - to be merged with CFG.SH.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
DAT=2.0

TYP=(JSN COD CFG)
if [[ -z $BAS ]]; then
	. ./bas.sh
fi

# READ DATA from $1 to array by type
function read_data {
	local fd l k v
	exec {fd}<$1
	while IFS= read -u$fd l; do
		if [[ $l =~ ^"# DATA" ]]; then
			break
		fi
	done
	IFS="=" read k v <<< "$l"
	if [[ ! ${TYP[*]} =~ $v ]]; then
		return 1
	fi
	read_$v $fd
	exec {fd}<&-
}

# READ COD DATA into $code
function read_COD {
	local l k s
	declare -g -A code
	while IFS= read -r -u$1 l; do
		if [[ $l =~ ^"# END" ]]; then
			break
		fi
		if [[ "${l: -1}" == ":" && ! $l =~ " " ]]; then	# *
			if [[ $s ]]; then
				code[$k]=$s
				s=
			fi
			k=${l:0: -1}
			continue
		fi
		s+="$l"$'\n'
	done
	if [[ $s ]]; then
		code[$k]=$s
	fi
}
# * Fucking Python... And labels will need a comment... And???

# READ JSN DATA into $jsn
function read_JSN {
	local l k v
	declare -g -A jsn
	while IFS= read -u$1 l; do
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
}

# READ CFG DATA of file to named Globals
function read_CFG {
	local l b k v
	while read -r -u$1 l; do
		if [[ $l == "" ]]; then
			continue
		fi
		if [[ $l =~ ^"# END" ]]; then
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
}

# READ CFG FILE into Globals
# ALT # NUY
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
# ALT # NUY # read_cfga coderun.cfg
function read_cfga {
	local k v
	declare -g -A ${1%.*}
	local -n r=${1%.*}
	while read -r k v; do
		if [[ ${k:0:1} == ";" ]]; then
			continue
		fi
		r[$k]=$v
	done <$1
}

# END

# TEST

if [[ ${BASH_ARGV[@]} =~ -c ]]; then
	echo "${!code[@]}"
	exit
fi

return

# NOTES

All the "file readers" are unforgiving (no error handlers) and expect proper 
formatting: no leading spaces; no tabs; no trailing comments; etc. Blank lines 
are generally okay. Only the CFG format uses commented lines. This is so that 
Bash Parameter Expansion is all that is needed to parse the data.
