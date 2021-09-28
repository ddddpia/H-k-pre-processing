#! /bin/python3.9

#this scrip is used for intercepting earthquake events 
# and writing event information
# written by junliu @IGGCAS 2021.9.22
# modified by pdx

import numpy as np
import obspy
from obspy import UTCDateTime
from obspy.core import read
import os
import datetime
#When you want to call the sac statement to add an earthquake event, 
#you need to call the following two commands
#which are not used in this program
import subprocess
import sys



os.putenv("SAC_DISPLAY_COPYRIGHT", '0')


def return_sac_name(serial_number,datetime,component):
# the function is used to return the format sac file name
# i.e. change the "453007502.2021_8_1_00_00_00_07502_XX_SHE.SAC"
#      into "453007502.2021_08_01_00_00_00_07502_XX_SHE.SAC"

# input var:        serial_number: string 
#                   datetime: UTCDateTime
#                   component: N/E/Z
# output var:       format sac file name
    if datetime.month < 10:
        real_month = "0{}".format(datetime.month)
    else:
        real_month = "{}".format(datetime.month)

    if datetime.day < 10:
        real_day = "0{}".format(datetime.day)
    else:
        real_day = "{}".format(datetime.day)    

    sac_file_name = "{}.{}_{}_{}_00_00_00_{}_XX_SH{}.SAC".format(serial_number,
                datetime.year,real_month,real_day,serial_number[4:9],component)
    return sac_file_name

def return_sac_name_after(serial_number,datetime,component):
# the function is used to return the format sac file name
# i.e. change the "453007502.2021_8_1_00_00_00_07502_XX_SHE.SAC"
#      into "453007502.2021_08_01_00_00_00_07502_XX_SHE.SAC"

# input var:        serial_number: string 
#                   datetime: UTCDateTime
#                   component: N/E/Z
# output var:       format sac file name
    if datetime.month < 10:
        real_month = "0{}".format(datetime.month)
    else:
        real_month = "{}".format(datetime.month)

    if datetime.day < 10:
        real_day = "0{}".format(datetime.day)
    else:
        real_day = "{}".format(datetime.day)    
    
    sta_file = open("/home/pdx/H-k-c-test2/hk_pro_decon/test_data/lolael.txt","r")
    stas = sta_file.readlines()

    for j in range(len(stas)-1):
       if serial_number == stas[j].strip().split()[4]:
            sac_file_name = "{}.{}_{}_{}_{}_{}_{}_{}_XX_SH{}_{}.SAC.cut".format(serial_number,
                            datetime.year,real_month,real_day,datetime.hour,
                            datetime.minute,datetime.second,serial_number[4:9],component,
                            stas[j].strip().split()[0])
    
    return sac_file_name


def add_evens_info(category,evlo,evla,evdp,mag):
    
#the function is used to add the events' information to the seismic data
#including events' longitude, latitude,depth and magnetic.
#input var:         category:int
#                   (evlo,evla,evdp)mag's pointer position corresponding to the earthquake catalog:int
#output var:        stream with events' information
   
    tr = st[0]
    tr.stats.sac['evlo'] = categorys[category].strip().split()[evlo]
    tr.stats.sac['evla'] = categorys[category].strip().split()[evla]
    tr.stats.sac['evdp'] = categorys[category].strip().split()[evdp]
    tr.stats.sac['mag'] = categorys[category].strip().split()[mag]
    st[0] = tr

    return st



# read the index of earthquake 
# the format of index is in the cate file
category_file = open("/home/pdx/H-k-c-test2/sacdata_pre_processing/cate","r")
categorys = category_file.readlines()

# the continuous seismic data folder
continuous_seismic_data_folder = "/home/pdx/H-k-c-test2/hk_pro_decon/test_data"
# the data is gather by serial number like 453008790
serial_numbers = os.listdir(continuous_seismic_data_folder)

components = ["N","E","Z"]





count = 0
for i in range(len(categorys)-1):
    if i == 0:
        #skip the title
        continue

    date = categorys[i].strip().split()[0]
    time = categorys[i].strip().split()[1]
    
    earthquake_happen_time  = UTCDateTime("{}T{}".format(date,time))-8*3600
    print("dongxue: normal: deal with earthquake {}".format(earthquake_happen_time))

    for serial_number in serial_numbers:
        if '45300' not in serial_number:
            continue
        os.chdir(os.path.join(continuous_seismic_data_folder,serial_number))

        headtime = earthquake_happen_time
        tailtime = earthquake_happen_time + 3600


        for component in components:
            if headtime.julday is not tailtime.julday:
                # sac continue seismic data recording exceeds "one day"

                sac_file_name_1 = return_sac_name(serial_number,headtime,component)
                sac_file_name_2 = return_sac_name(serial_number,tailtime,component)
                if os.path.exists(os.path.join(continuous_seismic_data_folder,serial_number,sac_file_name_1)):
                    print("dongxue: normal: find the sac file1 successful")
                else:
                    print("dongxue: warning: could not find the sac file1 successful")
                    continue
                if os.path.exists(os.path.join(continuous_seismic_data_folder,serial_number,sac_file_name_2)):
                    print("dongxue: normal: find the sac file2 successful")
                else:
                    print("dongxue: warning: could not find the sac file2 successful")
                    continue

                #join two seismic records firstly and then cut seismic events
                st = read(sac_file_name_1)
                st += read(sac_file_name_2)
                st.merge(method=1)
                st = st.slice(headtime,tailtime)

                st = add_evens_info(i,4,3,5,2)

                
                #tr = st[0]
                #tr.stats.sac['evlo'] = categorys[i].strip().split()[4]
                #tr.stats.sac['evla'] = categorys[i].strip().split()[3]
                #tr.stats.sac['evdp'] = categorys[i].strip().split()[5]
                #tr.stats.sac['mag'] = categorys[i].strip().split()[2]
                #st[0] = tr

                #write the processed data directly into the original file
                #sac_file_name_after = return_sac_name_after(serial_number,headtime,component)
                #st.write(sac_file_name_after,format="SAC")


                #write the processed data to the new file

                new_sac_file_folder = "/home/pdx/H-k-c-test2/hk_pro_decon/new_test_data/new_{}".format(serial_number)
                sac_file_name_after = return_sac_name_after(serial_number,headtime,component)
                if os.path.exists(new_sac_file_folder):
                    new_sac_file_name = os.path.join(new_sac_file_folder,sac_file_name_after)
                    st.write(new_sac_file_name,format="SAC")
                else:
                    new_sac_file_folder = os.mkdir("/home/pdx/H-k-c-test2/hk_pro_decon/new_test_data/new_{}".
                                                    format(serial_number))  
                    new_sac_file_name = os.path.join(new_sac_file_folder,sac_file_name_after)
                    st.write(new_sac_file_name,st,format="SAC")




            else:
                sac_file_name = return_sac_name(serial_number,headtime,component)

                if os.path.exists(os.path.join(continuous_seismic_data_folder,serial_number,sac_file_name)):
                    print("dongxue: normal: find the sac file successful")
                else:
                    print("dongxue: warning: could not find the sac file successful")
                    continue
                


                #cut seismic events
                st = read(sac_file_name)
                st = st.slice(headtime,tailtime)

                st = add_evens_info(i,4,3,5,2)



                #write the processed data to the new file
                new_sac_file_folder = "/home/pdx/H-k-c-test2/hk_pro_decon/new_test_data/new_{}".format(serial_number)
                sac_file_name_after = return_sac_name_after(serial_number,headtime,component)
                if os.path.exists(new_sac_file_folder):
                    new_sac_file_name = os.path.join(new_sac_file_folder,sac_file_name_after)
                    st.write(new_sac_file_name,format="SAC")
                else:
                    os.mkdir("/home/pdx/H-k-c-test2/hk_pro_decon/new_test_data/new_{}".format(serial_number)) 
                    new_sac_file_folder = "/home/pdx/H-k-c-test2/hk_pro_decon/new_test_data/new_{}".format(serial_number)
                    new_sac_file_name = os.path.join(new_sac_file_folder,sac_file_name_after)
                    st.write(new_sac_file_name,format="SAC")

                print(st[0].stats)

