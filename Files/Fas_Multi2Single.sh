#!/bin/bash

# convert Multi-line Fasta to Single-line

# run Fas_Multi2Single.sh within a folder that contains fasta files with extension .fas or .fasta
# all of which are "multi-line" fasta. An "out"-folder will be created containing with the same files
# all as "single-line" fasta.

if [ -d "out" ]
then
	echo "operation aborded: directory 'out' already exist"
else
	mkdir out
	#for i in *.fas *.fasta
	for i in $(ls | egrep '\.(fas){1}(ta)?$')
	do
		awk '/^>/ { if(NR>1) print "";  printf("%s\n",$0); next; } { printf("%s",$0);}  END {printf("\n");}' < $i > ./out/$i
	done
fi