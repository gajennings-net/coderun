# BAS.SH - Basics Shit
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings

dt() {
	local d="+%x %X"
	if [[ $1 ]]; then
		d=$1
	fi
	date "$d"
}

# htmlentities
hen() {
	local s
	s="${1//&/\&amp;}"
	s="${s//</\&lt;}"
	s="${s//>/\&gt;}"
	if [[ $2 ]]; then
		s="${s//'"'/\&quot;}"
		s="${s//"'"/\&#039;}"
	fi
	echo "$s"
}

hun() {
	local s
	s="${1//\&amp;/&}"
	s="${s//\&lt;/<}"
	s="${s//\&gt;/>}"
	if [[ $2 ]]; then
		s="${s//\&quot;/'"'}"
		s="${s//\&#039;/"'"}"
	fi
	echo "$s"
}

# isset
is() {
	if [[ -n $(declare -p $1 2> /dev/null) ]]; then
		echo 1
	fi
}

isA() {
	if [[ $(declare -p $1 2> /dev/null) =~ -A ]]; then
		echo 1
	fi
}

echoe() {
	echo "$*"
}

die() {
	echo -n "$*"
	exit
}

enc() {
	local s
	s=${1//\"/\\\"}
	s=${s//$'\n'/\\n}
	echo "$s"
}

dec() {
	local s
	s=${1//\\\"/\"}
	s=${s//\\n/$'\n'}
	echo "$s"
}

# END
