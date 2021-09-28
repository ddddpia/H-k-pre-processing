#!/bin/bash

# written by junliu @IGGCAS 2021.8.30
# this script is used for pre-processing of receiver function calculation
# adding the info of cmpaz/cmpinc  

# modified by dongxue@mail.iggcas.ac.cn 2021.9.27
#####

cd ./new_test_data

#new station file name 
#if you continue to run following the previous step
#the file already exists, you can comment out the following command

#ls -d new_4530* > new_sta.txt  

while read nstaName
do
	cd $nstaName

	#Write the name of the data file to be processed into the list
	#here, we only choose the processed data (we have already gotten before)
    #of course, you can also choose the original data,
	# but you need to change the order in which scrips are run

	#ls *.SAC.cut.sl > sac_cut_mark.txt

	while read nsacName
	do
	cmp=`echo $nsacName | awk -F"." '{print $2}' | awk -F"_" '{print $9}'`
	echo $cmp
 

	
# deal with different component 
	# see sac manual page 31
	

	if [[ $cmp = "SHN" ]]; then
	#TODO: to check if the BH1 stands for north 
	
		sac << EOF
r ${nsacName}
ch cmpaz 0 
ch cmpinc 90
wh
q
EOF
fi
	if [[ $cmp = "SHE" ]]; then
		sac << EOF
r ${nsacName}
ch cmpaz 90 
ch cmpinc 90
wh
q
EOF
fi
	if [[ $cmp = "SHZ" ]]; then
		sac << EOF
r ${nsacName}
ch cmpaz 0 
ch cmpinc 0
wh
q
EOF
fi
	
		sac << EOF
r $nsacName
rtr; rmean; taper
bp co 0.05 2 n 4 p 2

q
EOF


	done < sac_cut_mark.txt
	cd ..	
done < new_sta.txt
