#!/usr/bin/env bash

height=15
[ -z $1 ] || height=$1
lim=$height
#clear
printf "%${lim}s" && printf "\033[1;31m*" && printf "%${lim}s"
echo -e "\033[1;32m"
i=0 ; j=$i
while (( $i < $lim )); do
    [ $(($i % 4 )) = 0 -a $i != $j ] && j=$i && i=$(($i-2))  
    printf "%$(($lim - $i))s" 
    printf "^%.0s" $(seq 1 $(( 2*$i+1 ))) 
    printf "%$(($lim - $i))s"
    echo
    i=$(($i+1))
done
echo -en "\033[0;33m"
printf "%$(($lim-1))s" && printf "|||" && printf "%$(($lim-1))s"
echo

exit

ball(){
    echo -en "\033[s"
    x=$1; y=$2
    echo -en "\033[${x};${y}HO"
    echo -en "\033[u"
}
echo -en "\033[1;31m"
for _ in $(seq 100); do
    h=$(( $height - 1))
    y=$(( $RANDOM % $height-1 + 3))
    l=$(( $y - 1 ))
    x=$(( $RANDOM % (7*$l/4 + 1 ) + $height - 3*$l/4 ))
    ball $y $x
done
