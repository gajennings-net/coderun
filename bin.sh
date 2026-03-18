# BIN.SH - The DATA for the binaries; self configuring. See NOTES.
# Part of coderun.cgi, the localhost code runner; or, Experiment in the Shell.
# Copyright 2026 g.a.jennings
BIN=1.0

# EXTERNAL DATA
if [[ -z $option ]]; then
	option=php
fi
declare "option_$option"=checked

# MODULE DATA

declare -a bins

function bin_read {
	local l b k v
	exec {fd}<${BASH_SOURCE[0]}
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
			bins+=($b)
			declare -g -A $b
			continue
		fi
		k=${l%% *}; v=${l#* }; v=${v%\"}; v=${v#\"}
		declare -g -n r=$b
		r[$k]="$v"
	done
	exec {fd}<&-
}

# CONNECT TO FORM option
function bin_option {
	local a opt=${1:-$option}
	for a in ${bins[@]}; do
		if [[ $a == $opt ]]; then
			declare -g -n bin=$opt
			break
		fi
	done
	for a in ${!bin[@]}; do
		declare -g $a="${bin[$a]}"
	done
#echo "$bin, $tmp, $name, $desc etc."
}

bin_read

# END

# TEST

function bin_show {
	local a b
	for a in ${bins[@]}; do
		echo "[$a]"
		declare -n r=$a
		for b in ${!r[*]}; do
			if [[ ${r[$b]} =~ " " ]]; then
				echo "$b \"${r[$b]}\""
			else
				echo "$b ${r[$b]}"
			fi
		done
	done
}

# RUN TIME

if [[ ${BASH_ARGV[@]} =~ -s ]]; then
	bin_show
fi
if [[ ${BASH_ARGV[@]} =~ -t ]]; then
	bin_test
fi

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	exit
fi

return

# END

# NOTES

This contains the data (in INI-like format) for the known code running 
programs, PHP, Bash, C, etc. Just put them here and it should work... 

# DATA
[php]
bin "php"
tmp php.tmp
name PHP
desc "PHP Code"
pre "<?php "
[sh]
bin sh
tmp sh.tmp
name Bash
desc "Shell script"
[perl]
bin perl
tmp pl.tmp
name Perl
desc "Perl script"
[ruby]
bin ruby
tmp rb.tmp
name Ruby
desc "Ruby Code"
[python]
bin python
tmp py.tmp
name Python 
desc "Python Code"
[lua]
bin lua
tmp lua.tmp
name Lua
desc "Lua Script"
[gcc]
bin gcc
tmp c.c
name C
desc "C Code"
comp 1
[rust]
bin rustc
tmp a.rs
name Rust
desc "Rust Code"
comp 1
[go]
bin "go run"
tmp tmp.go
name Go
desc "Go Lang"
pre "package main;"
# END


ruby:
puts "Hello, World!"

python:
print("Hello, World!")

perl:
print "Hello, World!";

c:
#include <stdio.h>
int main()
{
    printf("Hello, World!");
}

rust:
fn main() {
    println!("Hello, world!");
}

g++:
#include <iostream>
using namespace std;
int main() 
{
    cout << "Hello, World!";
    return 0;
}

lua:
print ("Hello, World!")

go:
import "fmt"
func main() {
    fmt.Println("Hello, world")
}
