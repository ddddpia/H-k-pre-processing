#!/bin/bash


# written by junliu @IGGCAS 2021.8.30
# this script is used for receiver function calculation

#modified by dongxue@mail.iggcas.ac.cn 2021.9.27
#####

cd ./new_test_data

#ls -d new_4530* > new_sta.txt

while read nstaName
do
	cd $nstaName
	#ls *.SAC.cut.sl | awk -F"_" '{print $1"_"$2"_"$3"_"$4"_"$5}' | sort | uniq > sac_sort.txt
	#station number
	staNum=`ls *.SAC.cut.sl | awk -F"." '{print $2}' | awk -F"_" '{print $10}' | awk '!a[$0]++'`

	#you can also use the following commamd to get station number
	#but you should be sure that you have proceed the previous scrips
	#staNum=`ls *.SAC | awk -F"." '{print $3}' | awk '!a[$0]++'`

	while read nsacName
	do
		iter_decon -N100 -C8/-10/80 -T0.1 $nsacName*SHZ*sl $nsacName.$staNum.SH[R,T].SAC 
		# before calculating the rf, there are some info should be placed in sac file header
		
		# rayp should be placed in user0
		# theoretical traveltime should be placed in user8
		
	done < sac_sort.txt
	
	# output will be renamed by *i
	cd ..	
done < new_sta.txt
