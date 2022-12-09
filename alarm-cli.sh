#!/bin/bash

#options
#
#	-m : make the volume 100% if not already equal to or greater than
#
#	-l : pass the argument hh:mm:ss
#
#	-a : pass the audio file/directory

#default variables
maxvolume=0
audiofile="audio/"
interactive=1

#handle flags
while getopts "ma:l:" flag
do
        case "${flag}" in
                m)
		  maxvolume=1
		  ;;
		a)
		  audiofile="$OPTARG"
		  ;;
                l)
		  interactive=0
		  longstyle="$OPTARG"
                  ;;
        esac
done

playdir () {
        cvlc -Z "$audiofile"*
}

playfile () {
        cvlc "$audiofile"
}
maximizevolume () {
        rawvolume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk 'NR==1{print $5}')
        #100%
        #
        volume=${rawvolume::"${#rawvolume}"-1}
        #100
        #
        #increase by this value
        #
        increaseby=$(( 100 - "$volume"))
        #only increase if called for
        #
        increaseit="0"
        #if the volume is somehow currently negative, increase it anyway
        #if the volume is normal and not 100, increase it by $increaseby
        #
        if [[ "$increaseby" -gt 101 ]]; then
                #do the thing
                increaseit="1"
        fi
        if [[ "$increaseby" -eq 0 ]]; then
                #do the thing
                increaseit="1"
        fi

        #unmute just in case
        #
        pactl set-sink-mute @DEFAULT_SINK@ 0

        #increase the volume by increaseby if the filter allows
        #
        if [[ "$increaseit" -eq 1 ]]; then
                pactl set-sink-volume @DEFAULT_SINK@ +"$increaseby"%
                echo "volume is now $(pactl get-sink-volume @DEFAULT_SINK@ | awk 'NR==1{print $5}')"
        fi
}

playalarm () {
        if [[ "$maxvolume" == 1 ]]; then
                maximizevolume;
        fi
        if [ -d "$audiofile" ]; then
                local checker="${audiofile:0-1}"
                if [ "$checker" = "/" ]; then
                        playdir;
                else
                        audiofile="$audiofile""/"
                        playdir;
                fi
        else
                playfile;
        fi
}

#derive seconds function
math4alarm () {
        hsecs=$(( "$hours" * 60 * 60 ))
        msecs=$(( "$minutes" * 60 ))
        totalsecs=$(( "$hsecs" + "$msecs" + "$seconds"))
        echo "alarm set for ""$totalsecs"" seconds from now"
}

#split up long style
splitlongstyle () {
	hours=$(echo "$longstyle" | awk -F ":" '{print $1}')
	minutes=$(echo "$longstyle" | awk -F ":" '{print $2}')
	seconds=$(echo "$longstyle" | awk -F ":" '{print $3}')
}

#request timer function
timer () {
	if [[ "$interactive" == 0 ]]; then
		splitlongstyle;
		return;
	else
		echo "hours: (default is 0)"
		read hours
		if [ -z "$hours" ]; then hours=0; fi
		echo "minutes: (default is 0)"
		read minutes
		if [ -z "$minutes" ]; then minutes=0; fi
		echo "seconds: (default is 0)"
		read seconds
		if [ -z "$seconds" ]; then seconds=0; fi
		echo "do you want the volume to automatically adjust to 100%? [y/n/default=n]"
		read response0
		if [ "$response0" = "y" ]; then maxvolume=1; fi
	fi
}

main () {
	#get the timer value
	timer;

	#get the seconds total
	math4alarm;

	#wait, maximize if set, play file/directory
	sleep "$totalsecs" && playalarm;
}

main;
