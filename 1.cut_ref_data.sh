#! /bin/bash

#written by dongxue@mail.iggcas.ac.cn 2021.9.27
#this script is used for cutting data of calcucating receive function



#Enter the new data folder which earthquake events have been added
#/new_test_data is your own data file

cd ./new_test_data
ls -d new_4530* > new_sta.txt

while read nstaName #new station name
do
	nstaName=`echo $nstaName | sed -e 's/\r//g'`
	cd $nstaName
	ls *.SAC.cut > sac_cut.txt
	while read nsacName #cut data
	do
		sac << EOF
r $nsacName
wh
q
EOF
		gcarc=`saclst gcarc f $nsacName | awk -F" " '{print $2}'`
		evdp=`saclst evdp f $nsacName | awk -F" " '{print $2}'`
		bTime=`saclst b f $nsacName | awk -F" " '{print $2}'`

		pTime=`taup time -mod iasp91 -ph P -h $evdp -deg $gcarc | awk -F" " '{print $4}' | sed -n '6p'`
		
		if [[ $gcarc > 30 && $gcarc < 90 || $gcarc == 30 || $gcarc == 90 ]];then
            #echo $gcarc     #check whether the if statement is running
            			
			sac << EOF
r $nsacName
cut ($bTime + $pTime - 30) ($bTime + $pTime + 30)
r $nsacName
w $nsacName.sl
q
EOF
		
			#save the data file name that can be used for receiving function calculations into a txt file
			if [[ ! -s sac_cut_mark.txt ]];then
			ls $nsacName.sl >> sac_cut_mark.txt   #pick up az(30,90)   	

			elif [[ $(cat sac_cut_mark.txt | grep -i "$nsacName") ]];then
			#delete duplicate rows which include "*.cut"
			sed -i "/${nsacName}/d" sac_cut_mark.txt  
			ls $nsacName.sl >> sac_cut_mark.txt
			#echo haha   #test
			fi
	
		fi

		 
	done < sac_cut.txt
	cd ..
done < new_sta.txt
