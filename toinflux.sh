#!/bin/bash

#path to directory which contain folders with timestamp name
filepath="/path/to/folder/with RVTools reports folders with dd.mm.yyyy_HH-mm name formats"
#array with path to each file with RVTools name
path="$(find $filepath -type f -name "RVTools_tab*")" 
#sample name
filename="RVTools_tab*.csv"

#delete "\r" from all files
find $filepath -type f -name $filename -exec sed -i ':a;N;$!ba;s/\r//g' {} \;
# delete all commas in files
find $filepath -type f -name $filename -exec sed -i 's/,//g'  {} \;
# switch from ";" to ","
find $filepath -type f -name $filename -exec sed -i 's/;/,/g'  {} \;

#add tag at the begining to each string in each file
for i in ${path}; do
base=$(basename "$i" '.csv')
environment=$(echo "$i" | cut -d'/' -f7- | rev | cut -d'/' -f2- | rev)
# echo ${environment}
sed -i s/^/$environment-$base,/g "$i"
done
#add timestamp from path to file to the end of each string in each file
for i in ${path}; do
dateandtime=$(echo "$i" | cut -d'/' -f6- | rev | cut -d'/' -f3- | rev)
#echo ${dateandtime}
for t in ${dateandtime}; do
reverteddate=$(echo "$t" | sed -E 's,([0-9]{2})\.([0-9]{2})\.([0-9]{4})_([0-9]{2})-([0-9]{2}),\3-\2-\1T\4:\5:00\.999999Z,g')
sed -i s/$/,${reverteddate}/g "$i" 
done
done

find $filepath -type f -name $filename -exec sed -i '1 s/.\{29\}$/,Date/'  {} \;     #replace last word at 1st string to "date" in each file

# #add influxdb data annotation in 1st string
for i in ${path}; do
# # headers=$(sed -n '2p' "$i")
# # echo ${headers}
count=$(head -1 "$i" | sed 's/[^,]//g' | wc -c)
# # echo ${count}
for I in ${count[@]}; do 
    string=$(printf ',string%.0s' $(eval echo "{1..$I}"))
    # #echo ${string}
    sed -i 1i""${string}"" $i
done
done

#replace first two headers to important with flux 
find $filepath -type f -name $filename -exec sed -i '1 s/^,string,string/#datatype measurement,tag/'  {} \; 
#replace last word to datetime format header
find $filepath -type f -name $filename -exec sed -i '1 s/,string$/,dateTime:RFC3339/'  {} \;

#push data from all files to influx bucket
for i in ${path}
do
influx write -b test -f $i
done
