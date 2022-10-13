set -e

# wget http://ultravideo.fi/video/Beauty_1920x1080_120fps_420_8bit_YUV_RAW.7z
# 7z e Beauty_1920x1080_120fps_420_8bit_YUV_RAW.7z

INPUT=Beauty_1920x1080_120fps_420_8bit_YUV.yuv

rm -f /tmp/freqfile.yuv
rm -rf build/*
cmake -B build -S . #-DOJPH_NOP_BWD_TRANSFORMS=ON # -DCMAKE_BUILD_TYPE=Debug #Release #Debug
make -j20 -C build
make -C build install DESTDIR=/tmp/
export LD_LIBRARY_PATH=/tmp/usr/local/lib/
/tmp/usr/local/bin/ojph_compress -reversible true -num_decomps 2 -dims \{1920,1080\} -bit_depth 8,8,8 -num_comps 3 -i $INPUT -o $INPUT.ojh -signed false,false,false -downsamp \{1,1\},\{2,2\}

#/tmp/usr/local/bin/ojph_compress -reversible true -num_decomps 2 -dims \{1920,1080\} -precincts \{8192,2\},\{8192,2\},\{8192,2\},\{8192,2\},\{8192,4\} -block_size \{1024,4\} -prog_order PCRL -bit_depth 8,8,8 -num_comps 3 -i $INPUT -o $INPUT.ojh -signed false,false,false -downsamp \{1,1\},\{2,2\}
#/tmp/usr/local/bin/ojph_compress -reversible true -dims \{1920,1080\} -bit_depth 8,8,8 -num_comps 3 -i $INPUT -o $INPUT.ojh -signed false,false,false -downsamp \{1,1\},\{2,2\}
#
/tmp/usr/local/bin/ojph_expand -i $INPUT.ojh -o $INPUT.ojh.yuv

dd if=$INPUT bs=$((1920*1080*3/2)) count=1 | md5sum
dd if=$INPUT.ojh.yuv bs=$((1920*1080*3/2)) count=1 | md5sum

#gprof -l /tmp/usr/local/bin/ojph_expand ./gmon.out > gprof.txt
#LD_LIBRARY_PATH=/tmp/usr/local/lib/ gcov /tmp/usr/local/bin/ojph_expand ./gmon.out > gcov.txt

#sudo perf record -g /tmp/usr/local/bin/ojph_expand -i $INPUT.ojh -o $INPUT.ojh.yuv

# view decoded output
#ffplay -v info -f rawvideo -pixel_format yuv420p -video_size 1920x1080 $INPUT.ojh.yuv

#ffplay -v info -f rawvideo -pixel_format yuv420p -video_size 1920x1080 /tmp/freq.yuv
