cd to the folder destionation

### 1024x768
ffmpeg -f alsa -ac 2 -i pulse -f x11grab -r 30 -s 1024x768 -i :0.0 -acodec pcm_s16le  -vcodec libx264 -preset ultrafast -crf 0 -threads 0 wp-record.mkv

### 1920x1080
ffmpeg -f alsa -ac 2 -i pulse -f x11grab -r 30 -s 1920x1080 -i :0.0 -acodec pcm_s16le  -vcodec libx264 -preset ultrafast -crf 0 -threads 0 wp-record.mkv
