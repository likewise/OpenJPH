#!/bin/bash

export LD_LIBRARY_PATH=`pwd`/../:`\pwd`/../../bin
export PATH=/bin:/usr/bin:`pwd`/../:`\pwd`/../../bin

# compress and decompress the images
if [ "$1" = "-dec" -o "$1" = "-rdec"  ]; then
  if ! kdu_compress $2; then
    echo "===========>" kdu_compress error
    exit 1
  fi
elif [ "$1" = "-enc" -o "$1" = "-renc" ]; then
  if ! ojph_compress $2; then
    echo "===========>" ojph_compress error  
    exit 1
  fi
else
  exit 1
fi
if ! kdu_expand $3; then
  echo "===========>" kdu_expand error
  exit 1
fi
if ! ojph_expand $4; then
  echo "===========>" ojph_expand error
  exit 1
fi

# test PSNR and maximum error
out1=$(../psnr_pae $5 $6)
if [ $? -ne 0 ]; then
  echo "===========>" psnr_pae error at location 1
  exit 1
fi
out2=$(../psnr_pae $5 $7)
if [ $? -ne 0 ]; then
  echo "===========>" psnr_pae error at location 2
  exit 1
fi

rm -f test.j2c test.jph $6 $7

psnr1=$(echo $out1 | cut -f1 -d' ')
psnr2=$(echo $out2 | cut -f1 -d' ')
d1=$(bc -l <<< "$psnr1 - $psnr2")
d1=${d1##*[+-]}

pae1=$(echo $out1 | cut -f2 -d' ')
pae2=$(echo $out2 | cut -f2 -d' ')
d2=$(($pae1 - $pae2))
d2=${d2##*[+-]}

if [ "$1" = "-renc" -o "$1" = "-rdec" ]; then
  if [ "$psnr1" = "inf" -a "$psnr2" = "inf" -a "$pae1" = "0" -a "$pae2" = "0" ]; then
    exit 0
  else
    echo "===========>" PSNR or PAE error
    echo psnr1 = $psnr1, psnr2 = $psnr2, pae1 = $pae1, pae2 = $pae2
    exit 1
  fi
else
  t=$(bc -l <<< "$d1 > 0.01 || $d2 > 1")
  if [ $t -eq 0 ]; then
    exit 0
  else
    echo "===========>" PSNR or PAE error
    echo psnr1 = $psnr1, psnr2 = $psnr2, pae1 = $pae1, pae2 = $pae2
    exit 1
  fi
fi
