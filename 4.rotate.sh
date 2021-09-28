#!/bin/bash

# written by junliu@IGGCAS
# this script is used for rotating the seismograms from NEZ corrdinate to RTZ 

#modifed by dongxue@mail.iggcas.ac.cn 2021.9.27


cd ./new_test_data

#ls -d new_4530* > new_sta.txt

while read nstaName
do
	cd $nstaName
	ls *.SAC.cut.sl | awk -F"_" '{print $1"_"$2"_"$3"_"$4"_"$5}'  | sort | uniq > sac_sort.txt
	#station number
	staNum=`ls *.SAC.cut.sl | awk -F"." '{print $2}' | awk -F"_" '{print $10}' | awk '!a[$0]++'`

	while read nsacName
	do
		sac << EOF
r $nsacName*SH[N,E]*.sl
rotate to gcp
traveltime model iasp91 picks 0 phase P S
w $nsacName.$staNum.SHR.SAC $sacName.$staNum.SHT.SAC
q
EOF
	done < sac_sort.txt
	cd ..	
done < new_sta.txt
