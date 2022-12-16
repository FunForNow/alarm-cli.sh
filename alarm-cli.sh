#!/bin/bash

#default variables
maxvolume=0
audiofile="audio/"
interactive=1
inputL=0
inputT=0
goodtimer=0
dowcatch=0
Mhours=0
Mminutes=0
Mseconds=0
hours=0
minutes=0
seconds=0
daysinseconds=0
notISOorDOW=1

#options
#handle flags
while getopts "va:t:i:dh:m:s:" flag
do
        case "${flag}" in
                v)
                  maxvolume=1
                  ;;
                a)
                  audiofile="$OPTARG"
                  ;;
                t)
                  inputT=1
                  longstyle="$OPTARG"
                  ;;
                i)
                  #handle more input
                  moreinputval="$OPTARG"
                  inputI=1
		  ;;
		d)
		  #debug
		  testit=1
		  ;;
                h)
                  #handle more input
                  Mhours="$OPTARG"
                  manualL=1
                  ;;
                m)
                  #handle more input
                  Mminutes="$OPTARG"
                  manualL=1
                  ;;
		s)
                  #handle more input
                  Mseconds="$OPTARG"
                  manualL=1


        esac
done

#echo "variables initialized"

#default lists
daysoftheweek=(
        "mon"
        "tue"
        "wed"
        "thu"
        "fri"
        "sat"
        "sun"
)

#daysoftheweekinteger
mon=1
tue=2
wed=3
thu=4
fri=5
sat=6
sun=7

#echo "daysoftheweek initialized"

playdir () {
        cvlc -Z "$audiofile"*
}

playfile () {
        cvlc "$audiofile"
}
maximizevolume () {
        #initial variables
        rawvolume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk 'NR==1{print $5}')
        volume=${rawvolume::"${#rawvolume}"-1}
        increaseby=$(( 100 - "$volume"))
        #
        increaseit="0"
        #if the volume is somehow currently negative, increase it anyway
        #if the volume is normal and not 100, increase it by $increaseby
        #
        if [[ "$increaseby" -lt 101 ]]; then
                #dont raise by 0
                if [[ "$increaseby" -gt 0 ]]; then
                        increaseit="1"
                fi
        fi
        #unmute just in case
        #
        pactl set-sink-mute @DEFAULT_SINK@ 0

        #increase the volume by increaseby if the filter allows
        #
        if [[ "$increaseit" -eq 1 ]]; then
                pactl set-sink-volume @DEFAULT_SINK@ +"$increaseby"%
#                echo "volume is now $(pactl get-sink-volume @DEFAULT_SINK@ | awk 'NR==1{print $5}')"
        fi
}

playalarm () {
        if [[ "$testit" == 1 ]]; then
		echo "sleeping for ${totalsecs}"
		echo "expected alarm at "$(date -d "${totalsecs} sec")
		exit
	fi
	echo "expected alarm at "$(date -d "${totalsecs} sec")
	sleep "$totalsecs"
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

splitlongstyle () {
	if [[ "$manualL" == 1 ]]; then
		hours="$Mhours"
		minutes="$Mminutes"
		seconds="$Mseconds"
	else
		delimiters=$( awk -F ':' '{print NF}' <<< "$longstyle" )
		if [[ "$delimiters" == 3 ]]; then
		        hours=$(echo "$longstyle" | awk -F ":" '{print $1}')
        		minutes=$(echo "$longstyle" | awk -F ":" '{print $2}')
	        	seconds=$(echo "$longstyle" | awk -F ":" '{print $3}')
		elif [[ "$delimiters" == 2 ]]; then
			hours=0
                        minutes=$(echo "$longstyle" | awk -F ":" '{print $1}')
                        seconds=$(echo "$longstyle" | awk -F ":" '{print $2}')
                elif [[ "$delimiters" == 1 ]]; then
                        seconds=$(echo "$longstyle" | awk -F ":" '{print $1}')
		else
			echo "error: I can't understand what you did wrong"
		fi

	fi
#	echo "hours: ""$hours"
#	echo "minutes: ""$minutes"
#	echo "seconds: ""$seconds"
	totalsecs=$(( $(( "$hours" * 3600 )) + $(( "$minutes" * 60 )) + "$seconds" ))
}
findthesoleseconds () {

        secondstilltarget=$(( $(date +%s -d "${datestringraw}") - $(date +%s) ))
	#the date commmand breaks when it's the same day.
        if [[ "$secondstilltarget" -lt 0 ]]; then
                #assume it's for tomorrow
                secondstilltarget=$(( 86400 + "$secondstilltarget" ))
        fi

        #return totalsecs and forgo the concatenation
        totalsecs="$secondstilltarget"
#	echo "seconds until target: ""$totalsecs"
}

findthetimeseconds () {
        timestring=$(echo "$datestringraw" | awk -F "@" '{print $2}')
#	echo "timestring: ""$timestring"
	#11/11 is arbitrary. easily interpret the string with date command and return seconds
	day0at0=$(date +%s -d "11/11")
	day0atX=$(date +%s -d "11/11 ${timestring}")
	secondsdiff=$(( "$day0atX" - "$day0at0" ))
	secondstilltarget="$secondsdiff"
#	echo "timeseconds: ""$secondstilltarget"
	#time since start of day
	secondssince=$(( $(date +%s) - $(date +%s -d "today 00:00") ))
}

requestdow () {
        for day in "${daysoftheweek[@]}"; do
                if [[ "$datestring" == "$day" ]]; then
                        userdow="${!day}"
                fi
        done
}

findthedowseconds () {
#returns days until target

	#find the dow value of the user's request (date command breaks if it is the same day, so do this manually)
        requestdow;
        #current day of the week
        currentdow=$(date +%u)

        #literally no clue how i figured this out, but it just works
        if [[ "$currentdow" -lt "$userdow" ]]; then
                daysuntil=$(( "$currentdow" + 1 - "$userdow" ))
                daysuntil=$(( "$daysuntil" * -1 ))
        elif [[ "$currentdow" -eq "$userdow" ]]; then
                daysuntil=6
        else
                daysuntil=$(( 7 - "$currentdow" + "$userdow" - 1 ))
        fi


	#i now have number of days to search for. append 1 to fill in the partial day
        daysuntil=$(( "$daysuntil" + 1))
	#then minus now
	secondsdiff=$(( $(date +%s -d "${daysuntil} day 00:00") - $(date +%s) ))
	#now we have seconds until the start of the target day
#	echo "dowseconds: ""$secondsdiff"
	daysinseconds="$secondsdiff"
}


findtheISOseconds () {

        daysinseconds=$(( $(date +%s -d "${datestring}") - $(date +%s) ))
        #remove negative numbers (if it is today, for example)
        if [[ "$daysinseconds" -lt 0 ]]; then
		daysinseconds=0
		if [[ $(date +%j -d "${datestring}") -lt $(date +%j) ]]; then
			appendyear=$(( $(date +%Y) + 1 ))
			if [[ $(date +%Y -d "$datestring") -lt $(date +%Y) ]]; then
#				echo "error: this year is from the past"
				exit;
			fi
			datestring="$appendyear""/""$datestring"
			findtheISOseconds;
		fi
	fi
#	echo "isoseconds: ""$daysinseconds"

}


findthedateseconds () {
        datestring=$(echo "$datestringraw" | awk -F "@" '{print $1}')

        if [[ "$datestring" == *"/"* ]]; then
                #its an ISO date format
#		echo "findtheisoseconds ();"
                findtheISOseconds;
                #returns daysinseconds
        else
                #remove all but first three chars

                #iterate through days of the week to see if this is one of them
                for item in "${daysoftheweek[@]}"; do

                        #if it succeeds, then it is a day of the week
                        if [[ $( grep "$item" <<< "$datestring") ]]; then
#                                echo "findthedowseconds ();"
				datestring="$item"
                                findthedowseconds;
                                #returns days till target
                                #throw a catch so weird strings work
				notISOorDOW=0
                        fi
                done
		if [[ "$notISOorDOW" == 1 ]]; then
#			echo "not an ISO or DOW"
#			echo "datestring: ${datestring}"
			daysinseconds=$(( $(date +%s -d "${datestring} 00:00") - $(date +%s) ))
			if [[ -z "$daysinseconds" ]]; then
				daysinseconds=0
			fi
		fi
        fi
}



moreinput () {

        #format to lowercase
        datestringraw=$(echo "$moreinputval" | awk '{print tolower($0)}')

        #is this is date@time request?
        #look for "@" because date requires @time
        if [[ "$datestringraw" == *"@"* ]]; then
                #this has a days and time segment
                #determine if it is ISO or dow (day of week)
#                echo "this has day and time segments"
                #find the days until target date and calculate seconds
#                echo "findthedateseconds ();"
		findthedateseconds;
		#find the seconds until the target time
#		echo "findthetimeseconds ();"
                findthetimeseconds;

		totalsecs=$(( "$secondstilltarget" + "$daysinseconds" ))
                if [[ "$daysinseconds" == 0 ]]; then
			totalsecs=$(( "$secondstilltarget" - "$secondssince" ))
#			echo "compensate for date: today"
		else
			totalsecs=$(( "$secondstilltarget" + "$daysinseconds" ))
                fi


	#it isn't a date@time request, so...
        elif [[ "$datestringraw" == *"am"* ]] || [[ "$datestringraw" == *"pm"* ]]; then
                #this passes if there is no days segment and it is only time
#                echo "findthesoleseconds ();"
		#find the seconds until the target time
                findthesoleseconds;
        fi
}


setalarm () {
#create a catch to prevent the command from continuing if the params are incorrect
        if [[ "$inputI" == 1 ]]; then
                moreinput;
		if [[ "$inputT" == 1 ]]; then
			echo "error: use either -t or -i"
			echo "do not use both"
		fi
                return;
        elif  [[ "$inputT" == 1 ]] && [[ "$manualL" == 1 ]]; then
                echo "error: use -l or use -h,-m,-s"
                echo "dont use -l with -h,-m, or -s"
                exit;
        elif [[ "$inputT" == 1 ]] || [[ "$manualL" == 1 ]]; then
                splitlongstyle;
                return;
        else
                echo "error: no argument passed"
		echo "use -t to set a timer (hh:mm:ss)"
		echo "use -i to set an alarm (11/11@11:11:11pm)(6am)(tuesday@6am)"
                exit;
        fi
}


main () {
        #get the timer value
        setalarm;
        playalarm;
}

main;

