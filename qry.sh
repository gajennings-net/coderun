# QRY.SH - The Query Data.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
QRY=1.0

Qa=(option post data button text below args html diag only clean)

declare -A _GET
declare -A _POST

for a in ${Qa[@]}; do
	declare $a=""
done

if [[ $REQUEST_METHOD == "POST" ]]; then
	if [[ $CONTENT_LENGTH -gt 0 ]]; then
		read -n $CONTENT_LENGTH POST_STRING <&0
	fi
fi

if [[ ${#POST_STRING} -gt 0 ]]; then
	POST_STRING=${POST_STRING//+/ }
	POST_STRING=${POST_STRING//%0D/}
	POST_STRING=${POST_STRING//%/\\x}
fi

if [[ $Qa ]]; then
	I=$IFS
	IFS='&'
	for q in $POST_STRING; do
		for a in ${Qa[@]}; do
			if [[ $q == $a* ]]; then
				v=$(echo -e "${q#*=}")
				declare $a="$v"
				break
			fi
		done
	done
	IFS=$I
fi

if [[ ! -n $_NOPOST ]]; then
	I=$IFS
	IFS='&'
	for q in $POST_STRING; do
		k=${q%%=*}
		v=$(echo -e "${q#*=}")
		_POST[$k]=$v
	done
	IFS=$I
fi

if [[ -n $(declare -p _GET 2> /dev/null) ]]; then
	I=$IFS
	IFS='&'
	for q in $QUERY_STRING; do
		k=${q%%=*}
		v=$(echo -e "${q#*=}")
		_GET[$k]=$v
	done
	IFS=$I
fi

unset -v I q a k v

query() {
	local a
	echo "[data]"
	for a in ${Qa[@]}; do
		declare -n v="$a"
		echo "$a"
#		echo "$a=$v"		# ALT
#		echo "\"$a\":\"$v\""	# ALT
	done
}

if [[ ${BASH_ARGV[@]} =~ -t ]]; then
	echo "${_GET[@]}"
#	echo "${_GET[@]}"
#	query
fi

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	exit
fi

return

# NOTES

#DATA
[data]
option
post
data
button
text
below
args
html
diag
only
# END
