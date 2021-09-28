#!/bin/bash


# written by junliu@IGGCAS
# this script is used for adding the information to sac file header
# rayp / 

#modified by dongxue@mail.iggcas.ac.cn 2021.9.27


cd ./new_test_data

#ls -d new_4530* > new_sta.lst
while read nstaName
do
	cd $nstaName
	#ls *.SAC.cut.sl > sac_cut_mark.txt
	while read nsacName
	do
		evdp=`saclst evdp f $nsacName  | awk -F" " '{print $2}'`
		gcarc=`saclst gcarc f $nsacName |  awk -F" " '{print $2}'`
		pTime=`taup time -mod iasp91 -ph P -h $evdp -deg $gcarc | awk -F" " '{print $4}' | sed -n '6p'`
		rayp=`echo " scale=4 ; $pTime / 111" | bc`
		# change the unit from s/deg to s/km
		# http://blog.sina.com.cn/s/blog_62389d9d0102yi6a.html
		
		echo $rayp
		sac << EOF
r $nsacName
traveltime model iasp91 picks 8 phase P S
ch user0 $rayp
wh
q
EOF
# picks 8 means to storage the result at user8

	done < sac_cut_mark.txt
	cd ..	
done < new_sta.txt
