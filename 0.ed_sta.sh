#! /bin/bash

#written by dongxue@IGGCAS
#this scrip is used for supplementoring point information
#including stalo, stala, stael, stap


#Enter the origin data folder which have never been edited before
#/new_test_data is your own data file
cd ./test_data 
ls -d 4530* > sta.txt
while read staName   #station name
do
    staName=`echo $staName | sed -e 's/\r//g'`
	echo $staName
	while read line
	do
		line=`echo $line | sed -e 's/\r//g'`
		# remove the return(\n) of ending 
	    stap=`echo $line | awk -F" " '{print $5}'`
       	stalo=`echo $line | awk -F" " '{print $2}'`
       	stala=`echo $line | awk -F" " '{print $3}'`
	    stael=`echo $line | awk -F" " '{print $4}'` 

	    if [[ $stap = $staName ]]; then
			echo $stap
		 	cd $staName
			ls *.SAC > sac.lst
			while read sacName
			do
			sac<<EOF
r ${sacName}
ch STLA $stala
ch STLO $stalo
ch STEL $stael
wh
q
EOF
            done < sac.lst #end while read sacName
			cd ..
		fi
	done < lolael.txt
done < sta.txt
