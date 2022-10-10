set -e

# wget http://ultravideo.fi/video/Beauty_1920x1080_120fps_420_8bit_YUV_RAW.7z
# 7z e Beauty_1920x1080_120fps_420_8bit_YUV_RAW.7z

# sudo mount -t tmpfs tmpfs ./tmp/

#modetest

#43=connector
#41=crtc
#39=overlay plane
#40=plane


#~/sandbox/htj2k/libdrm/tests/modetest/modetest \
#-M xlnx -s 43:1920x1080@RG16 -P 39@41:1920x1080@YU12 -w 40:alpha:40 #-a #-v
## -a

#exit

rm -rf build
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
make -C build -j4
make -C build -j4 install DESTDIR=/tmp/

INPUT=./tmp/Beauty_1920x1080_420_8bit.yuv

rm -f /tmp/freqfile.yuv

export LD_LIBRARY_PATH=/tmp/usr/local/lib/
BEGIN_NS=`date +%s%N`

ls -ald $INPUT.ojh

#for i in {1..1} #$(seq 1 1 20)
#do 
  /tmp/usr/local/bin/ojph_expand -i $INPUT.ojh -o $INPUT.ojh.$i.yuv&
#done
wait
END_NS=`date +%s%N`

echo $BEGIN_NS
echo $END_NS

PERIOD_NS=$(($END_NS - $BEGIN_NS))
PERIOD_MS=$((PERIOD_NS / 1000000))
echo $PERIOD_NS ns or $PERIOD_MS ms


