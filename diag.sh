# Diag Little - The local include that includes the real include if you got it. 
DIAGSRC="/srv/www/htdocs/diag/diag-1.0.4.sh"
if [[ ! -f $DIAGSRC ]]; then
#	message="diag missing"
	function diag {
		:
	}
	return 0
fi

for a in ${BASH_ARGV[@]}; do
	if [[ $a == DIAG* ]]; then
		k=${k%%=*}
		v=${a#*=}; v=${v%\"}; v=${v#\"}
		declare "$k=$v"
	fi
done
unset -v a k v

. $DIAGSRC
if [[ $? != 0 ]]; then
#	message="failed to load"
	return 1
fi

diag_config "diag.cfg"
diag -t 3			# trap ERR (new)
diag "diag: $PWD"
if [[ $DIAGONEXIT ]]; then
	diag -onexit "diag_$DIAGONEXIT"
fi

#message="diag loaded"

# EXTRA

diag_env() {
env | sort
}

diag_error() {
cat /var/log/httpd/error.log
}

diag_server() {
local k v s=(LOCALHOST GETWAY_INTERFACE DOCUMENT_ROOT QUERY_STRING HTTP_COOKIE 
REMOTE_HOST REMOTE_ADDR REQUEST_METHOD REQUEST_SCHEME REQUEST_URI REDIRECT_STATUS
REDIRECT_URL REDIRECT_QUERY_STRING SERVER_SOFTWARE SERVER_NAME SERVER_PROTOCOL
SCRIPT_NAME SCRIPT_FILENAME)
echo "SERVER:"
for k in "${s[@]}"; do
	declare -n v="$k"
	echo "$k = $v"
done
}

diag_bash() {
local k v b=( BASH BASH_VERSION BASH_ARGV0 BASHOPTS BASHPID 
BASH_COMMAND BASH_COMPAT BASH_ENV BASH_EXECUTION_STRING BASH_LOADABLES_PATH 
BASH_SUBSHELL BASH_XTRACEFD )
for k in "${b[@]}"; do
    declare -n v="$k"
    echo "$k=$v,"
done
b=( BASH_REMATCH BASH_ARGC BASH_ARGV FUNCNAME BASH_LINENO BASH_SOURCE 
BASH_VERSINFO )
for k in "${b[@]}"; do
    declare -n v="$k"
    echo "$k={${v[@]}}",
done
}

# END

# NOTES
