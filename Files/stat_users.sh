#!/bin/bash

# title			: stat_users.sh
# description	: export and sort PSQL query using bash shell script
# 				  this script collects user statistics for the Galaxy database
# author		: dsjg
# date			: 2020-10-27
# version		: 1.0
# usage			: bash stat_users.sh
# notes			: script requires sudo and assumes existence of user postgres
#				  and psql database galaxydb
# bash_version	: 4.4.19

# outfile name
outfile=user_stats_$(date +'%Y-%m-%d_%Hh%Mm').txt

# test if temp- and outfile exist; exit if they do, create them if they don't
if [[ -e "user_stats.tmp" || -e "$outfile" ]]; then
	printf "script terminated:\n user_stats.tmp or user_stats.txt already exist\n" && exit 1
else
	touch user_stats.tmp "$outfile"
fi

# create date variable for outfile header
today=$(date +'%Y-%m-%d  %H:%M')

# PSQL query; result in tempfile
sudo -u postgres -H -- psql -d galaxydb -c "SELECT email,username,disk_usage,deleted,purged,active FROM galaxy_user" >> user_stats.tmp

# filter and sort the tempfile sequentially to create outfile
# header
printf "\nUser Statistics log file: $today\n\n" >> $outfile
# column names
head -n 2 user_stats.tmp >> $outfile
# entries that have a mailaddress on top (sorted alphabetically)
tail -n +3 user_stats.tmp | egrep "@" | tr [:upper:] [:lower:] | sort -n >> $outfile
# followed by entries that are only represented by hashes (ascending by filesize)
tail -n +3 user_stats.tmp | head -n -2 | egrep -v "@" | sort -t\| -rnk3 >> $outfile
# number of entries
tail -n 2 user_stats.tmp | head -n 1 >> $outfile

# remove 
rm user_stats.tmp