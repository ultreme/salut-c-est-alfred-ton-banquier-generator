#!/bin/sh

LETTERS="a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9"

set -x
cd ../voices

for voice in $(say -v ? | awk '{print $1}'); do
    mkdir -p osx_$voice
    for letter in $LETTERS; do
        DEST=osx_$voice/$letter
        if [ -f $DEST.wav ]; then
            echo "already exists"
        else
            say -v $voice -f wave -o $DEST.wave $letter
            mv $DEST.wave $DEST.wav
        fi
    done
done
