acodec=$(ffprobe -v 0 -of csv=p=0 -select_streams a:0 -show_entries stream=codec_name "output.mkv")
if [ "$acodec" == "vorbis" ] || [ "$acodec" == "opus" ]; then
	audiostr="-acodec copy"
else
	audiostr="-acodec libopus -b:a 512k"
fi

ffmpeg -i "output.mkv" -vcodec libvpx-vp9 -pix_fmt yuv420p -g 240 -crf 28 -vf scale=-2:1080 -r 60 $audiostr -map_metadata -1 -row-mt 1 -tile-columns 2 compressed.webm
