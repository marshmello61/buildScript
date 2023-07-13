#    The Build Script by @marshmello61


#    Copyright (C) 2021 github.com/marshmello61

#    Licensed under the GNU General Public License, Version 3.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#    https://github.com/marshmello61/buildScript/blob/master/LICENSE

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

#!/bin/bash

# ==================================

# Include parameters
. buildScript/variables.conf

# Do not change below
FNAME="$RNAME*.zip"
ROM="$RNAME"

# ===================================

CLEAN=""
LOG=""
TG=""
UPLOAD=""

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
    echo "Usage: bash buildScript/build.sh -d <device> [OPTION]

Example:
    bash buildScript/build.sh -d sanders -l -c -t --derp

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
       echo -n "Your Telegram Username: @"
       read TGNAME
    fi
fi

# Set my own two roms. Coz why not
if [[ "${ROM}" == "derp" ]]; then
    echo " "
    echo "Setting up DerpFest parameters"
    LUNCH="derp"
    MKA="mka derp"
    RNAME="DerpFest"
    FNAME="$RNAME*.zip"
elif [[ "${ROM}" == "evo" ]]; then
    echo " "
    echo "Setting up Evolution-X parameters"
    LUNCH="evolution"
    MKA="mka evolution"
    RNAME="$LUNCH"
    FNAME="$RNAME*.zip"
fi

# If ROM is empty then ask for it
if [ -z "${ROM}" ]
then
   echo " "
   echo "Didn't you just forget to enter the name of the ROM you were tryna build? Huh?"
   sleep 3
   echo "Fine Nvm, Just Tell the name now!"
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
   FNAME="$RNAME*.zip"
   MKA="mka bacon"
   ROM="$RNAME"
fi

rm -rf clean file bruu

if [ -z "${OUT}" ]
then
   OUT=(out/target/product/${DEVICE})
fi

ZIP_PATH=$(find $OUT -maxdepth 1 -type f -name "${FNAME}" | sed -n -e "1{p;q}")
ZIP=$(basename $ZIP_PATH)

# Say hello to your master
echo " "
echo "Heyy ${TGNAME}, how's it goin'? Hope you're fine! Now let's get to some work shall we?"
echo " "

# If file exsists then prompt to upload it, then prompt to delete existing file
if [ -z ${ZIP_PATH} ]
then
   echo "Let me check...umm.. I don't see any file in there..."
   sleep 2
   mkdir file
else
   echo "Welp! I found a build in there!"
   if [[ "${UPLOAD}" == "upload" ]]; then
       read -e -p "Want me to upload it? [y/n] " choice
       [[ "$choice" == [Yy]* ]] && echo "Uploading file...." && gdrive upload ${ZIP_PATH} && echo " " || echo "Okay master"
   fi
   read -e -p "Umm okay, then should I just delete it? [y/n] " choice
   [[ "$choice" == [Yy]* ]] && echo "Deleting file...." && rm -rf ${ZIP_PATH} && echo " " && mkdir file || echo "that was a no, keeping file"
fi

if [[ "${TG}" == "tg" ]]; then
    . buildScript/telegram "Heyy Guys! ${TGNAME} has started building ${RNAME} for ${DEVICE}"
fi

# Create a empty directory so further decisions should be taken
read -e -p "Do you want to build rom? [y/n] " choice
[[ "$choice" == [Yy]* ]] && mkdir bruu || echo "Kekkk"

if [ -e bruu ]
then
   if [[ "${CLEAN}" == "clean" ]]; then
       echo " "
       echo "Clean building"
       rm -rf out
       if [[ "${TG}" == "tg" ]]; then
           . buildScript/telegram "He'll be clean building ${RNAME}, might take few hours (if no error xD)"$'\n'"I'll let you know once it's done, I'm keeping a watch on it"
       fi
   else
       echo " "
       echo "Dirty building"
       if [[ "${TG}" == "tg" ]]; then
           . buildScript/telegram "He's just dirty building, it'll be done soon, wait for it"
       fi
   fi
fi

if [ -e bruu ]
then
    rm -rf out/error.log
    . build/envsetup.sh && lunch ${LUNCH}_${DEVICE}-${TYPE} && ${MKA}
fi


ZIP_PATH=$(find $OUT -maxdepth 1 -type f -name "${FNAME}" | sed -n -e "1{p;q}")
ZIP=$(basename $ZIP_PATH)
# After build is done, it would appear in out directory
# If file appears then would prompt for uploading
# If file doesn't exists, that means build has been stopped, so it will warn
if [ -e bruu ]
then
   if [ -e file ]
   then
      if [ -e ${OUT}/${FNAME} ]
      then
         echo "Hey master, your build is done and ready to upload"
         if [[ "${TG}" == "tg" ]]; then
             if [[ "${UPLOAD}" == "upload" ]]; then
                 . buildScript/telegram "Welp, build is successful."$'\n'"Let me inform ${TGNAME} to Upload it!"
             fi
         fi
         echo ""
         if [[ "${UPLOAD}" == "upload" ]]; then
             read -e -p "Do you want me to upload file for you? [y/n] " choice
             [[ "$choice" == [Yy]* ]] && gdrive upload ${ZIP_PATH} && echo "Checking Gdrive wen? kthnxbye" || echo "Well, your choice! I go awei"
         fi

         FILENAME='```'$''$ZIP$'''```'
         #check md5sum
         md5sum=$(md5sum ${OUT}/${ZIP} | awk '{print $1}')
         md5summ='```'$''$md5sum$'''```'
         #md5sum check done
         #check file size
         size=$(ls -sh $OUT/$ZIP | awk '{print $1}')
         sizee='```'$''$size$'''```'
         # Telegram message only if upload exists
         if [[ "${TG}" == "tg" ]]; then
             if [[ "${UPLOAD}" == "upload" ]]; then
                 . buildScript/telegram -M "The test build is up now!"$'\n'" "$'\n'"Uploaded file details:"$'\n'"Name- ${FILENAME}"$'\n'"Size- ${sizee}"$'\n'"md5sum- ${md5summ}"$'\n'" "$'\n'"If you wanna test, just PM @${TGNAME} or ping him in his support group!"
                 . buildScript/telegram "I'll see y'all again when ${TGNAME} makes a new build, Bye!"
             fi
         fi
         # Telegram message only if upload not exists
         if [[ "${TG}" == "tg" ]]; then
             if [[ "${UPLOAD}" == "" ]]; then
                 . buildScript/telegram -M "The build of ${ROM} is successful."$'\n'" "$'\n'"Name- ${FILENAME}"$'\n'"Size- ${sizee}"$'\n'"md5sum- ${md5summ}"
             fi
         fi
      else
         echo "Oopsemiee. Looks like something interrupted building"
         echo "If that wasn't you, then something fucked up"
         echo "Well whatever it is, fix it and we'll start building again!"
         if [[ "${LOG}" == "log" ]]; then
             if  [[ -f "out/error.log" ]] && [[ -s "out/error.log" ]]; then
                  if [[ "${TG}" == "tg" ]]; then
                      . buildScript/telegram "Ooof, looks like Something fucked up, let me inform ${TGNAME} about it and he'll just fix it up!"
                      cp out/error.log out/$RNAME-$DEVICE-error.log
                      . buildScript/telegram -f out/$RNAME-$DEVICE-error.log | tee
                      rm -rf out/$RNAME-$DEVICE-error.log
                  fi
                  echo -n "Read log?[y/n]: "
                  read log
                  if [[ "${log}" == 'y' ]]; then
                      echo "Opening error log file" && sleep 3
                      nano out/error.log
                  fi
             else
                  if [[ "${TG}" == "tg" ]]; then
                      . buildScript/telegram "Well looks like @${TGNAME} isn't in the mood to make a build right now, whenever he is, I'll inform y'all!"
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
