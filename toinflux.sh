#!/bin/bash
filepath="find/path/to/folder/which/contains/RVTools/reports"                     #path to directory which contain folders with timestamp name
path="$(find $filepath -type f -name "RVTools_tab*")"                             #array with path to each file with RVTools name
filename="RVTools_tab*.csv"                                                       #sample name

find $filepath -type f -name $filename -exec sed -i ':a;N;$!ba;s/\r//g' {} \;     #delete "\r" from all files
find $filepath -type f -name $filename -exec sed -i 's/,//g'  {} \;               # delet all comma in files
find $filepath -type f -name $filename -exec sed -i 's/;/,/g'  {} \;              # switch from ";" to ","

#add tag at the begining of each string in each files
for i in ${path}; do
base=$(basename "$i" '.csv')
environment=$(echo "$i" | cut -d'/' -f7- | rev | cut -d'/' -f2- | rev)            # cut filename from file path and add to variable
# echo ${environment}
sed -i s/^/$environment-$base,/g "$i"                                             # add tag 
done
#add timestamp from path to file to the end of each string in each file
for i in ${path}; do
dateandtime=$(echo "$i" | cut -d'/' -f6- | rev | cut -d'/' -f3- | rev)            # cut date from file path 
#echo ${dateandtime}
for t in ${dateandtime}; do
reverteddate=$(echo "$t" | sed -E 's,([0-9]{2})\.([0-9]{2})\.([0-9]{4})_([0-9]{2})-([0-9]{2}),\3-\2-\1T\4:\5:00\.999999Z,g') #formating date to influx data
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

find $filepath -type f -name $filename -exec sed -i '1 s/^,string,string/#datatype measurement,tag/'  {} \; #replace first two headers to headers which important with flux 

find $filepath -type f -name $filename -exec sed -i '1 s/,string$/,dateTime:RFC3339/'  {} \;                #replace last word to datetime tag format header

# this loop is needed to convert values ​​(e.g. CPU) from string to number format because inflow just shows those values 
# in a table and you can't create graphs
for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx 'CPUs' | cut -d: -f1)
#echo ${ref}
let "ref1="${ref}"-2"
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx 'Memory' | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx "Capacity MB" | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx "Provisioned MB" | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx "In Use MB" | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx "Free MB" | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx 'TotalCpu' | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx 'NumCpuCores' | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx "Effective Cpu" | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
#echo ${reflong}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx "NumCpuThreads" | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
#echo ${reflong}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done


for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx 'NumCpuThreads' | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx 'TotalMemory' | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done

for t in ${path}; do
ref=$(sed -n $'2s/,/\\\n/gp' "$t" | grep -nx "Effective Memory" | cut -d: -f1)
reflong=$(grep -o -i long "$t" | wc -l)
#echo ${ref}
let "ref1="${ref}"-2-"${reflong}""
#echo $ref1
sed -i "s|string|long|"$ref1"" $t 2>/dev/null
done
