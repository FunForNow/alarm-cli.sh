# alarm-cli.sh

## requires
- vlc
- awk
- pipewire (-m flag turns the volume to %100)

## options
-l  : pass a timer string without interactive 
      syntax: hours:minutes:seconds

-a  : point directly to the file/folder you want to source audio from.
      syntax: it's not picky
      folders: uses cvlc -Z to randomly choose a file
      
-m  : automatically increases the volume to 100% right before playing the audio file
      

## how to use
mkdir alarm

put script in the alarm directory

create a directory inside alarm called audio

place an audio file(s) inside the alarm/audio/ 

### examples

#### bash alarm-cli.sh -m -a ~/Music/ -l 5:30:0
#### bash alarm-cli.sh  
