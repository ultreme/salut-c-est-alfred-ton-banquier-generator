#!/bin/sh

cd ../voices
pwd=$(pwd)
for voice in *; do
    cd $pwd
    if [ -d $voice ]; then
        cd $pwd/$voice
        pwd
        for file in *.wav; do
            word=$(echo $file | sed 's/....$//')
            sox -r 44100 $word.wav $word.mp3
        done
    fi
done