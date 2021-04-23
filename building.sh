#!/bin/bash
umask 0000

USER=""

cd /home/$USER

umask 0000

# Initalize our things
ROMNAME=""
SOURCE=""
DEVICE=""
BUILDTYPE=""
LUNCH=""
BRUNCH=""
BACON=""
JOB=""

OUT="/home/$USER/$SOURCE/out/target/product/$DEVICE"

# TG settings

TOKEN=""
CHATID=""

# cd to dir

cd /home/$USER/$SOURCE

# Telegram send function

export BOT_MSG_URL="https://api.telegram.org/bot$TOKEN/sendMessage"
export BOT_BUILD_URL="https://api.telegram.org/bot$TOKEN/sendDocument"

tg_post_msg() {
        curl -s -X POST "$BOT_MSG_URL" -d chat_id="$2" \
        -d "parse_mode=html" \
        -d text="$1"
}

tg_error() {
        curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
        -F chat_id="$2" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html"
}


# Transfer.sh
up(){
	curl --upload-file $1 https://transfer.sh/
}

# CleanUp
cleanup() {
    if [ -f "$OUT"/*2021*.zip ]; then
        rm "$OUT"/*2021*.zip
    fi
    if [ -f log.txt ]; then
        rm log.txt
    fi
}

# Upload Build
upload() {
     if [ -f out/target/product/$DEVICE/*2021*zip ]; then
		zip=$(up out/target/product/$DEVICE/*2021*zip)
		echo " "
		echo "zip"
    END=$(date +"%s")
    DIFF=$(( END - START ))
    tg_post_msg  "<b>Build took *$((DIFF / 60))* minute(s) and *$((DIFF % 60))* second(s)</b>%0A%0A<b>Rom: </b> <code>$ROMNAME</code>%0A<b>Date: </b> <code>$BUILD_DATE</code>%0A<b>Link: </b> <code>$zip</code> <code>/home/$USER/$SOURCE</code>" "$CHATID"
    tg_error log.txt "$CHATID"

     fi
}

# Build
build() {
    source build/envsetup.sh
    lunch $LUNCH
   if $BRUNCH="yes" 
   then 
      brunch $DEVICE -j$JOB | tee log.txt
   fi
   
   if $BACON="yes"
   then 
      mka bacon -j$JOB | tee log.txt
   fi
  
}


# Let's start
BUILD_DATE="$(date)"
START=$(date +"%s")
tg_post_msg "<b>STARTING ROM BUILD</b>%0A%0A<b>Rom: </b> <code>$ROMNAME</code>%0A<b>Device: </b> <code>$DEVICE</code>%0A<b>version: </b> <code>$BUILDTYPE</code>%0A<b>Build Start: </b> <code>$BUILD_DATE</code> <code> " "$CHATID"

cleanup
build
check

