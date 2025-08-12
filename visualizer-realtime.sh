#!/bin/bash
file="$1"
res="$2"
vmult="$3"
sspeed="$4"
gamma="$5"
bgamma="$6"
afchain="$7"
vfchain="$8"

if [ -z "$file" ]; then
	echo "Usage: bash visualiser.sh [audio device] (resolution) (volume multiplier) (scroll speed) (sonograph gamma) (bargraph gamma) (audio filter chain) (video filter chain)"
	echo ""
	ffmpeg -f avfoundation -list_devices true -hide_banner -i ""
	exit
fi

if [ -z "$res" ]; then
	#res="4096x3072"
	#res="1920x1440"
	#res="1440x1080"
	res="1280x720"
fi
hres=$(echo "$res" | awk -F "x" '{ print $1 }')
vres=$(echo "$res" | awk -F "x" '{ print $2 }')

if [ -z "$vmult" ]; then
	#vmult="28"
	vmult="12.53"
fi

if [ -z "$sspeed" ]; then
	#sspeed="1.134"
	sspeed="2"
fi

if [ -z "$gamma" ]; then
	#gamma="3"
	gamma="2.35"
fi

if [ -z "$bgamma" ]; then
	#bgamma="3"
	bgamma="2.35"
fi

if [ -z "$afchain" ]; then
	#afchain="loudnorm=dual_mono=true:offset=12"
	#afchain="acopy"
	afchain="volume=4.5dB"
fi

if [ -z "$vfchain" ]; then
	vfchain="copy"
fi

sono_h=$(echo $hres $vres | awk '{ print int( ( (100 - (( $1 * 9 * 50 ) / ( 16 * $2 ))) * $2 ) / 200 ) * 2 }')
vconfig="cscheme=0|1|1|1|0|1:fontcolor=0x101010:font='family=sans-serif\:weight=50\:minspace=true':sono_h=$sono_h"
visualizer="$afchain,showcqt=s=$res:r=60:csp=bt709:$vconfig:count=$(echo $sspeed $sono_h | awk '{ print ($1 * $2)/90 }'):bar_v=$vmult*a_weighting(f):sono_v=$vmult*a_weighting(f):sono_g=$gamma:bar_g=$bgamma:tc=$(echo $sspeed | awk '{ print 0.17 / $1 }'),$vfchain[out0]"

ffmpeg -f avfoundation -i "none:$file" -f wav - | ffplay -an -fflags nobuffer -f lavfi "amovie=f=pipe:filename=\'pipe:0\',$visualizer"
