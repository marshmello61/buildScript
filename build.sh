# The Build Script by @marshmello61

#!/bin/bash

# ===================================
# Set the parameters below

# You need to set device by flag or set below
DEVICE=""

# Set the lunch command
# Example: If °lunch aosp_sanders-userdebug°
# Then         lunch LUNCH_DEVICE-TYPE
# TYPE is userdebug by default
LUNCH=""
TYPE="userdebug"

# Set the mka command
# Default is mka bacon
MKA="mka bacon"

# Set your Rom's final zip name Initial words
# Used for detecting zip name
# Example: If Rom's zip name is
# AOSP-10.0-20200607.zip then
# RNAME="AOSP"
RNAME=""

# Do not change below
FNAME="$RNAME*"
ROM="$RNAME"

# Set your telegram username below
# If Your username is @marshmello_61
# Then set marshmello_61
TGNAME=""

# Setting parameters end here
# ===================================

# Parameters
while [[ $# -gt 0 ]]
do
param="$1"

case $param in
    -d|--device)
    DEVICE="$2"
    shift
    ;;
    -c|--clean)
    CLEAN="clean"
    ;;
    -l|--log)
    LOG="log"
    ;;
    -t|--tg)
    TG="tg"
    ;;
    -u|--upload)
    UPLOAD="upload"
    ;;
    --derp)
    ROM="derp"
    ;;
    --evo)
    ROM="evo"
    ;;
    -h|--help)
    echo "Usage: bash script/build.sh -d <device> [OPTION]

Example:
    bash script/build.sh -d sanders -l -c -t --derp

Mandatory Parameters:
    -d, --device          device you want to build for

Optional Parameters:
    -c, --clean           clean build directory before compilation
    -l, --log             perform logging of compilation
    -u, --upload          for using gdrive as upload
    --derp                builds DerpFest
    --evo                 builds Evolution-X
    -t, --tg              sends telegram notification *use it only
                          if you had set TOKEN and CHAT id in telegram script"
    sleep 10
    exit
    ;;
esac
shift
done

# If device flag not exist then exit
if [[ -z ${DEVICE} ]]; then
    echo "You did not specify a device to build! This is mandatory parameter." && sleep 6 && exit
fi

# Prompt for telegram username if -t flag
if [[ "${TG}" == "tg" ]]; then
    if [ -z "${TGNAME}" ]
    then
       echo " "
       echo -n "Your Telegram Username without @ : "
       read TGNAME
    fi
fi

# Set my own two roms. Coz why not
if [[ "${ROM}" == "derp" ]]; then
    echo " "
    echo "Setting up DerpFest parameters"
    LUNCH="derp"
    MKA="mka kronic"
    FNAME="Derp*"
    RNAME="DerpFest"
elif [[ "${ROM}" == "evo" ]]; then
    echo " "
    echo "Setting up Evolution-X parameters"
    LUNCH"aosp"
    MKA="mka bacon"
    FNAME="Evol*"
    RNAME="Evolution-X"
fi

# If ROM is empty then ask for it
if [ -z "${ROM}" ]
then
   echo " "
   echo "Looks like you did not have any rom to build"
   sleep 3
   echo "Now on prompt just enter the thing you do for lunching rom"
   sleep 3
   echo " "
   echo "Example: if you do °lunch aosp_sanders-userdebug° then"
   echo "type aosp"
   sleep 3
   echo "Whatever you write after °lunch° just type that"
   sleep 3
   echo -n "Now say. What you do for lunching?: "
   read LUNCH
   echo " "
   echo "Now write initial words of your rom on prompt"
   sleep 3
   echo "Example: If your rom file name is"
   echo "°AOSP-10.0-20200606.zip°"
   sleep 2
   echo "Then type AOSP"
   sleep 1
   echo -n "Yeah. So what's your rom's file initials?: "
   read RNAME
   FNAME="$RNAME*"
   MKA="mka bacon"
fi

rm -rf clean file bruu

if [ -z "${OUT}" ]
then
   OUT=(out/target/product/${DEVICE})
fi
ZIP_PATH=$(find $OUT -maxdepth 1 -type f -name "${FNAME}.zip" | sed -n -e "1{p;q}")
ZIP=$(basename $ZIP_PATH)

# Say hello to your master
echo " "
echo "Hey Master, how are you ? Hope you having a good day..."
echo " "

# If file exsists then prompt to upload it, then prompt to delete existing file
if [ -e ${ZIP_PATH} ]
then
   echo "Your handmade Rom file exists"
   if [[ "${UPLOAD}" == "upload" ]]; then
       read -e -p "Do you want me to upload file? [y/n] " choice
       [[ "$choice" == [Yy]* ]] && echo "Uploading file...." && gdrive upload ${ZIP_PATH} && echo " " || echo "Okay master"
   fi
   read -e -p "Do you want me to delete the existing file? [y/n] " choice
   [[ "$choice" == [Yy]* ]] && echo "Deleting file...." && cd o*/t*/p*/s* && rm -rf D*p && echo " " && cd ../../../.. && mkdir file || echo "that was a no, keeping file"
else
   mkdir file
   echo ""
fi

if [[ "${TG}" == "tg" ]]; then
    . buildScript/telegram "Hey, everyone. The build script for ${RNAME} is started"
fi

# Create a empty directory so further decisions should be taken
read -e -p "Do you want to build rom? [y/n] " choice
[[ "$choice" == [Yy]* ]] && mkdir bruu || echo "Kekkk"

if [ -e bruu ]
   if [[ "${CLEAN}" == "clean" ]]; then
       echo " "
       echo "Clean building"
       rm -rf out
       if [[ "${TG}" == "tg" ]]; then
       . buildScript/telegram "Good news everyone. Dirty build of ${RNAME} started."$'\n'"If no error, it will be ready in almost 2 hours."
       fi
   else
       echo " "
       echo "Dirty building"
       if [[ "${TG}" == "tg" ]]; then
       . buildScript/telegram "Good news everyone. Dirty build of ${RNAME} started."$'\n'"It can be ready at anytime."
       fi
   fi
fi

if [ -e bruu ]
then
    rm -rf out/error.log
    . build/envsetup.sh && lunch ${LUNCH}_${DEVICE}-${TYPE} && ${MKA}
fi


ZIP_PATH=$(find $OUT -maxdepth 1 -type f -name "${FNAME}.zip" | sed -n -e "1{p;q}")
ZIP=$(basename $ZIP_PATH)
# After build is done, it would appear in out directory
# If file appears then would prompt for uploading
# If file doesn't exists, that means build has been stopped, so it will warn
if [ -e bruu ]
then
   if [ -e file ]
   then
      if [ -e ${ZIP_PATH} ]
      then
         echo "Hey master, your build is done and ready to upload"
         if [[ "${TG}" == "tg" ]]; then
             . buildScript/telegram "Well, the build is successful."$'\n'"Prompting to @${TGNAME} for uploading build"
         fi
         echo ""
         if [[ "${UPLOAD}" == "upload" ]]; then
             read -e -p "Do you want me to upload file for you? [y/n] " choice
             [[ "$choice" == [Yy]* ]] && gdrive upload ${ZIP_PATH} && echo "Go and grab that shit from your gdrive" || echo "Fine. Upload it manually"
         fi
	 #check md5sum
         md5sum=$(md5sum ${OUT}/${ZIP} | awk '{print $1}')
	 #md5sum check done
	 #check file size
	 size=$(ls -sh $OUT/$ZIP | awk '{print $1}')
         if [[ "${TG}" == "tg" ]]; then
             . buildScript/telegram "The build is uploaded to @${TGNAME}'s gdrive."$'\n'" "$'\n'"Uploaded file details:"$'\n'"Name- ${ZIP}"$'\n'"Size- ${size}"$'\n'"md5sum- ${md5sum}"$'\n'" "$'\n'"If you wanna test, just tag @${TGNAME}"
         fi
      else
         echo "Oopsemiee. Looks like something interrupted building"
         echo "If that wasn't you, then it's something wrong"
         echo "Try solving the error and run me again"
         if [[ "${LOG}" == "log" ]]; then
             if  [[ -f "out/error.log" ]] && [[ -s "out/error.log" ]]; then
                  if [[ "${TG}" == "tg" ]]; then
                      . buildScript/telegram "Bad news :(. The build has any error in compiling"$'\n'" "$'\n'"@${TGNAME} fix this."
                      . buildScript/telegram -f out/error.log | tee
                  fi
                  echo -n "Read log?: "
                  read log
                  if [[ "${log}" == 'y' ]]; then
                      echo "Opening error log file" && sleep 5
                      nano out/error.log
                  fi
             else
                  if [[ "${TG}" == "tg" ]]; then
                      . buildScript/telegram "Build has cancelled by @${TGNAME}"
                  fi
             fi
         fi
         echo ""
      fi
    else
       echo ""
    fi
else
   echo ""
fi

# Remove the bruu directory, so that running script second time will not give error
rm -rf bruu
rm -rf file
rm -rf clean
