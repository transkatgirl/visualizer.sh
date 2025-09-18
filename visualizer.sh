#!/bin/bash
file="$1"
res="$2"
fps="$3"
gamma="$4"
sspeed="$5"
tclamp="$6"
bgamma="$7"
afchain="$8"
vfchain="$9"

if [ -z "$file" ]; then
	echo "Usage: bash visualiser.sh [audio file] (resolution) (framerate) (gamma) (scroll speed) (timeclamp) (bargraph gamma) (audio filter chain) (video filter chain)"
	exit
fi

if [ -z "$res" ]; then
	#res="4096x2730"
	res="2560x1706"
	#res="1920x1280"
	#res="1440x960"
fi
hres=$(echo "$res" | awk -F "x" '{ print $1 }')
vres=$(echo "$res" | awk -F "x" '{ print $2 }')
if [ -z "$fps" ]; then
	#fps="120"
	fps="60"
fi

if [ -z "$sspeed" ]; then
	#sspeed="1" # corresponds to ffmpeg default
	sspeed="2"
fi

if [ -z "$tclamp" ]; then
	tclamp="1" # corresponds to ffmpeg default
fi

if [ -z "$gamma" ]; then
	#gamma="3" # ffmpeg default
	gamma="2.71828182"
fi

if [ -z "$bgamma" ]; then
	#bgamma="1" # ffmpeg default
	bgamma="$gamma"
fi

if [ -z "$afchain" ]; then
	afchain="loudnorm=dual_mono=true:offset=7.5"
	#afchain="acopy"
fi

if [ -z "$vfchain" ]; then
	vfchain="copy"
fi

sono_h=$(echo $hres $vres | awk '{ print int( ( (100 - (( $1 * 9 * 50 ) / ( 16 * $2 ))) * $2 ) / 200 ) * 2 }')
vconfig="cscheme=0|1|1|1|0|1:fontcolor=0x101010:font='family=sans-serif\:weight=50\:minspace=true':sono_h=$sono_h"
visualizer="$afchain,showcqt=s=$res:r=$fps:csp=bt709:$vconfig:count=$(echo $sspeed $sono_h $fps | awk '{ print (($1 * $2)/90) * (60/$3) }'):bar_v=16*a_weighting(f):sono_v=16*a_weighting(f):sono_g=$gamma:bar_g=$bgamma:tc=$(echo $sspeed $tclamp | awk '{ print (0.17 / $1) * $2 }'),$vfchain"

ffmpeg -i "$file" -pix_fmt yuv444p -acodec copy -vcodec libx264 -crf 0 -preset medium -filter_complex "[0:a]$visualizer" output.mkv
