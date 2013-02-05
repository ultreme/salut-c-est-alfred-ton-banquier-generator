#!/bin/sh

voice=$1
mkdir -p ../voices/$1
echo "Be ready, press control+d when you are ready, press control+c when you finished to pronounce the words"
for char in 0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z _ - '$' '&' '^' '%' '@' '!' '?' '('; do
    echo $char
    read
    rec ../voices/$1/$char.wav
done