## H-k-pre-processing
***written by junliu@IGGCAS 2021
modified by dongxue@mail.iggcas.ac.cn 2021***

#This script is used for the preprocessing of seismic records, including writing station and seismic event information, component rotation, de-averaging, de-trending, deconvolution, etc., and finally obtain data files that can be used for H-k-c (Zhu Lupei) calculations.
#Let’s take the processing of seismic data recorded by five stations as an example to show how the program runs.

#notes: When you run your own data, you need to pay attention to changing the path and file name of the data file in the program, which will be prompted in the actual operation later.

1.Codes(the filename: H-k-c-test2)
(0)prerequisities:
    Have SAC, Python, Obspy installed.

(1)sacdata_pre_processing (cut_event.py):
    Written by junliu, 2021.
    Modified by dongxue, 2021.
    This script is used for intercepting earthquake events and writing event information.

(2)hk_pro_decon:
   a) 0.ed_sta.sh 
      Written by dongxue, 2021.
      This script is used for supplementoring point information including stalo, stala, stael, stap.
   
   b) 1.cut_ref_data.sh
      Written by dongxue, 2021.
      This script is used for cutting data of calcucating receive function.
   
   c) 2.add_cmpaz_inc.sh
      Written by junliu,2021.
      Modified by dongxue, 2021.
      This script is used for adding the information of cmpaz/cmpinc.
      
   d) 3.travTime.sh
      Written by junliu, 2021.
      Modified by dongxue, 2021.
      This script is used for adding the rayp information to sac file header.
   
   e) 4.rotate.sh
      Written by junliu,2021.
      Modified by dongxue, 2021.
      This script is used for rotating the seismograms from NEZ corrdinate to RTZ.
   
   f) 5.decon.sh
      Written by junliu, 2021.
      Modified by dongxue, 2021.
      This script is used for receiver function calculation.


#we don't show the data file in the import codes, but you can fully understand the entire program running process through other input and output files.

2.Input files
(1)Station information file: lolael.txt, which includes the station number, instrument number, point longitude, latitude, elevation， depth.

(2)Earthquake event catalog：cate,  which includes earthquake event date, magnitude， latitude, longitude, depth.

(3)seismic data: test_data, which includes earthquake measured data of all stations. We choose five station data for testing.
    
3.Output files
(1)new_test_data:  generated after adding earthquake events information, also includes new data after cuting event information

(2)new_sta.txt, sac_cut.txt, sac_cut_mark.txt, sac_sort.txt: files recording the names of processed sata.
 
(3)results files: *.SAC.cut.sl    *.SH[R,T].SAC    *i
    notes: *i is the final result which will be used in H-k-c(zhu Lupei)
    
4. Steps

(1)cd sacdata_pre_processing,   python cut_event.py,    generate new_test_data file
(2)cd ..
(3)cd hk_pro_decon
(4)bash ./0.ed_sta.sh
(5)bash ./1.cut_ref_data.sh
(6)bash ./2.add_cmpaz_inc.sh
(7)bash ./3.travTime.sh
(8)bash ./4.rotate.sh
(9)bash ./5.decon.sh, this script will use iter_decon from H-k-c(Zhu Lupei)

#Notes: you should execute those scripts sequentially, otherwise errors may occur. If you want to avoid this problem, you can remove some comments in the script, where we have marked.

#Of course, you can write a new script to merge those scripts together, as a result, you can just run only a scrip.
#But you should be cautious whether the processing file right or not.

# Contributor
pdx: pandongxue20@mails.ucas.ac.cn
junliu: swjl2314@mails.jlu.edu.cn
