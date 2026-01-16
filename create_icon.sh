#!/bin/bash

# Create a simple PNG icon using ImageMagick (if available) or just create placeholder

SIZES="48 72 96 144 192"
DIRS="mdpi hdpi xhdpi xxhdpi xxxhdpi"

counter=0
for size in $SIZES; do
    dir_array=($DIRS)
    dir=${dir_array[$counter]}
    
    # Create a simple colored square as placeholder
    convert -size ${size}x${size} xc:none -fill '#6200EA' -draw "circle $((size/2)),$((size/2)) $((size/2)),0" -fill white -gravity center -pointsize $((size/3)) -annotate +0+0 "📜" android/app/src/main/res/mipmap-${dir}/ic_launcher.png 2>/dev/null || {
        # If ImageMagick is not available, just copy a placeholder
        echo "Placeholder icon for ${dir}" > android/app/src/main/res/mipmap-${dir}/ic_launcher.png
    }
    
    counter=$((counter+1))
done

echo "Icons created"
