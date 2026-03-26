# SRV.SH - Server Stuff.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
SRV=1.1

SCNT="text/html; charset=UTF-8"
SPBY="BASH/${BASH_VERSION%(*}"

export LANG=$LANG
export LC_ALL=$LANG

INDEX=${0##*/}
: ${HTTP_HOST:=localhost}
: ${SERVER_NAME:=${HTTP_HOST}}
: ${REQUEST_URI:=${PWD//"/srv/www/htdocs"/}/$INDEX}
: ${SCRIPT_NAME:=$REQUEST_URI}
: ${REMOTE_ADDR:=127.0.0.1}
: ${HTTP_USER_AGENT:=Mozilla/5.0 (X11; Linux x86_64)}
REQUEST_URI=${REQUEST_URI%%\?*}
REQUEST_URI=${REQUEST_URI//$INDEX/}

DIR=${SCRIPT_NAME%/*}
if [[ $DIR != "/" ]]; then
	DIR+="/"
fi
REQUEST_URI=${REQUEST_URI//$DIR/}

function header {
	echo "X-Powered-By: $SPBY"
	echo "Content-Type: $SCNT"
	echo ""
}

return

# END

# NOTES

Not all the data defined here are used. (This module not really needed, but...)
