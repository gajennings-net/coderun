# DAT.SH - Configuration Functions - to be merged with CFG.SH.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
DAT=1.1

TYP=(JSN COD CFG)
if [[ -z $BAS ]]; then
	. ./bas.sh
fi

# READ DATA from $1 to array name $2
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

# READ JSN DATA in $jsn
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

# READ CFG DATA of file to Global
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
	local -n cfg=${1%.*}
	while read -r k v; do
		if [[ ${k:0:1} == ";" ]]; then
			continue
		fi
		cfg[$k]=$v
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

# NOTED

Here are all the "NEW" choices (I think display arguments is far better way of 
introducing code than hello world...):

# DATA type=COD
gcc:
#include <stdio.h>
int main(int argc, char *argv[]) {
    for (int i = 0; i < argc; i++) {
        printf("arg %d: %s\n", i, argv[i]);
    }
    return 0;
}

sh:
i=0
for arg in "$@"; do
    echo "arg $i: $arg"
    i=$((i+1))
done

python:
import sys
for i, arg in enumerate(sys.argv):
    print(f"arg {i}: {arg}")

ruby:
ARGV.each_with_index do |arg, i|
  puts "arg #{i}: #{arg}"
end

perl:
for my $i (0 .. $#ARGV) {
    print "arg $i: $ARGV[$i]\n";
}

php:
foreach ($argv as $i => $arg) {
    echo "arg $i: $arg\n";
}

java:
public class Args {
    public static void main(String[] args) {
        for (int i = 0; i < args.length; i++) {
            System.out.println("arg " + i + ": " + args[i]);
        }
    }
}

go:
import "fmt"
import "os"
func main() {
    for i, arg := range os.Args {
        fmt.Printf("arg %d: %s\n", i, arg)
    }
}

rust:
fn main() {
    for (i, arg) in std::env::args().enumerate() {
        println!("arg {}: {}", i, arg);
    }
}

bat:
@echo off
setlocal enabledelayedexpansion
echo arg 0: %0
set i=1
for %%A in (%*) do (
    echo arg !i!: %%A
    set /a i+=1
)

lua:
for i = 0, #arg do
    print("arg " .. i .. ": " .. tostring(arg[i]))
end

cpp:
#include <iostream>
int main(int argc, char* argv[]) {
    for (int i = 0; i < argc; i++) {
        std::cout << "arg " << i << ": " << argv[i] << "\n";
    }
}

# END
