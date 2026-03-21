# DAT.SH - Configuration Functions - to be merged with CFG.SH.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
DAT=1.0

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
		if [[ "${l: -1}" == ":" && ! $l =~ " " ]]; then
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

# LOAD

read_data dat.sh

# END

# TEST

if [[ ${BASH_ARGV[@]} =~ -c ]]; then
	echo "${!code[@]}"
fi

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	exit
fi

return

# NOTES

This will be merged into CFG.SH, but as wih most of the code it's Good Enough 
for Now...

Here are all the "NEW" choices:

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
