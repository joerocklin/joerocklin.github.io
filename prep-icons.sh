#!/usr/bin/env bash
#
# Usage: prep-icons SOURCE TARGET
#
# SOURCE: any input file convert accepts
# TARGET: target directory for icon files
#
# Beware: Overwrites existing files in TARGET

if [[ ! $1 ]]
then
	echo "No source file specified."
	exit 1
else
	target=$2
	if [[ ! -d $target ]]
	then
		echo "Target directory not found."
		exit 1
	else
		set -x
		convert $1 -resize 57x57   $target/apple-touch-icon-57x57.png
		convert $1 -resize 60x60   $target/apple-touch-icon-60x60.png
		convert $1 -resize 72x72   $target/apple-touch-icon-72x72.png
		convert $1 -resize 76x76   $target/apple-touch-icon-76x76.png
		convert $1 -resize 114x114 $target/apple-touch-icon-114x114.png
		convert $1 -resize 120x120 $target/apple-touch-icon-120x120.png
		convert $1 -resize 144x144 $target/apple-touch-icon-144x144.png
		convert $1 -resize 152x152 $target/apple-touch-icon-152x152.png
		convert $1 -resize 180x180 $target/apple-touch-icon-180x180.png
		cp $target/apple-touch-icon-180x180.png $target/apple-touch-icon.png

		convert $1 -resize 16x16   $target/favicon-16x16.png
		convert $1 -resize 32x32   $target/favicon-32x32.png
		convert $1 -resize 64x64   $target/favicon-64x64.png
		convert $1 -resize 96x96   $target/favicon-96x96.png
		convert $1 -resize 160x160 $target/favicon-160x160.png
		convert $1 -resize 160x160 $target/favicon-160x160.ico
		convert $1 -resize 192x192 $target/favicon-192.192.png

		convert $1 -resize 64x64   $target/favicon.ico
		set +x

		# done
		echo "All icons created."
	fi
fi
