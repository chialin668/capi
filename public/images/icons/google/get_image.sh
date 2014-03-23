#!/bin/bash
echo getting images...

for ((i=1;i<=100;i+=1)); do
  echo $i
  wget http://www.google.com/base/s2/images/map$i.png
done
