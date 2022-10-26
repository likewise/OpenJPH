#!/bin/bash

set -e

# wget http://ultravideo.fi/video/Beauty_1920x1080_120fps_420_8bit_YUV_RAW.7z
# 7z e Beauty_1920x1080_120fps_420_8bit_YUV_RAW.7z

INPUT=Beauty_1920x1080_120fps_420_8bit_YUV.yuv
OUTDIR=Sequence
#rm -f /tmp/freqfile.yuv
#rm -rf build/*
#cmake -B build -S . #-DOJPH_NOP_BWD_TRANSFORMS=ON # -DCMAKE_BUILD_TYPE=Debug #Release #Debug
#make -j20 -C build
#make -C build install DESTDIR=/tmp/
export LD_LIBRARY_PATH=/tmp/usr/local/lib/

rm -rf $OUTPUT

# YUV 4:2:0 8-bit planar; both chroma channels have 1/4th pixels each
DELTA=$((1920*1080*3/2))

# generate HTJ2K OJH bitstreams named "%d.ojh", one per frame, starting with this number
OUTPUT_FRAME=0

# for now, skip 6 frames because the acquisition framerate was 120 Hz
# this normalizes the natural motion, but shortens the output sequence
# 120 / 6 = 20 Hz, ~20 Hz is the current single-threaded decode performance
INPUT_PACE=$((120/20))

# parallelize the encoding, 4 processes max (modify if needed, but needs >=1)
MAX_JOBS=8
JOBS=0
# iterate over 4:2:0 8-bit 1920x1080 YUV raw planar sequences
for INPUT in \
Beauty_1920x1080_120fps_420_8bit_YUV.yuv \
Bosphorus_1920x1080_120fps_420_8bit_YUV.yuv \
HoneyBee_1920x1080_120fps_420_8bit_YUV.yuv \
Jockey_1920x1080_120fps_420_8bit_YUV.yuv \
ReadySteadyGo_1920x1080_120fps_420_8bit_YUV.yuv \
ShakeNDry_1920x1080_120fps_420_8bit_YUV.yuv \
YachtRide_1920x1080_120fps_420_8bit_YUV.yuv
do
  INPUT_FRAME=0
  # calculate number of frames in sequence
  INPUT_SIZE=`stat -c %s ${INPUT}`
  FRAMES=$(($INPUT_SIZE / $DELTA))
  # iterate over input frames in the sequence
  while  [ $INPUT_FRAME -lt $FRAMES ]; do
    (echo Encoding $INPUT frame $INPUT_FRAME to $OUTDIR/$OUTPUT_FRAME.ojh;
      dd if=$INPUT of=/tmp/$OUTPUT_FRAME.yuv bs=$DELTA skip=$INPUT_FRAME count=1 status=none;
      /tmp/usr/local/bin/ojph_compress -reversible true -num_decomps 2 -dims \{1920,1080\} -bit_depth 8,8,8 -num_comps 3 -signed false,false,false -downsamp \{1,1\},\{2,2\} \
      -i /tmp/$OUTPUT_FRAME.yuv -o $OUTDIR/$OUTPUT_FRAME.ojh; rm -f /tmp/$OUTPUT_FRAME.yuv;
    ) &

    #(echo sleep $INPUT $OUTPUT_FRAME; sleep $OUTPUT_FRAME)&

    OUTPUT_FRAME=$(($OUTPUT_FRAME + 1))

    INPUT_FRAME=$(($INPUT_FRAME + $INPUT_PACE))

    # keep at most MAX_JOBS background encoding jobs running in parallel
    JOBS=$(($JOBS + 1))
    if [ $JOBS -ge $MAX_JOBS ]; then
      # wait for one encoding job to finish
      wait -n
      JOBS=$(($JOBS - 1))
    fi
  done
done
