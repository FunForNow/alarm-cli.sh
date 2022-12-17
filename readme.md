# alarm-cli.sh

## disclaimer
I might have tuned the script, but it's still a bash script.

use at your own caution - OR - grab the ideas you like and make your own script. 

## requires
- vlc

- awk

- date (unix command)

- grep

- pactl

## examples
#### basic alarms and timers
timers: 

      bash alarm-cli.sh -t 1                                (1 sec)

      bash alarm-cli.sh -t 1:1                              (61 sec)

      bash alarm-cli.sh -t 1:1:1                            (3661 sec)
            
      bash alarm-cli.sh -h 1 -m 1 -s 1                      (3661 sec)

alarms:

      bash alarm-cli.sh -i 2pm                              (nearest 2pm)
      
      bash alarm-cli.sh -i tue@2pm                          (nearest tuesday at 2pm)

      bash alarm-cli.sh -i 11/11@11:11:11pm                 (nearest 11/11 at 11:11:11pm)
      
      bash alarm-cli.sh -i tomorrow@6am                     (tomorrow at 6am)
      
      bash alarm-cli.sh -i 12/25                            (first second of christmas day)
      
      bash alarm-cli.sh -i tomorrow                         (first second of tomorrow)


      
other:

      bash alarm-cli.sh -i tomorrow@6am -v                  (maximize volume before playing alarm)
      
      bash alarm-cli.sh -i tomorrow@6am -d                  (show output without playing alarm)
      
      bash alarm-cli.sh -i tomorrow@6am -a ~/Music          (play random song from Music directory)

      
      
## options
-t  

      -t : timer 
      
      syntax: 
            
            hours:minutes:seconds
            
            minutes:seconds
            
            seconds

-i  

      -i : "moreinput"
      
      this uses the date command where it can and patches known issues
      
      to be perfectly clear, I dont know what all you can do with it.
      
      There are probably inputs I dont even know exist yet
      
-d

      -d : debug
      
      run it to determine output AND don't execute the sleep or audio
      
-v

      -v  : automatically increases the volume to 100% right before playing the audio file
      
      this uses the pactl, but so as to work with pipewire. 
      
      may or may not work for you.

-a

      -a : alarm-audio-file(s)
      
      pick a specifc file or directory instead of the default
      
      it morphs bad requests so all requests should function
      
      SHOULD. it's completely possible that you can break this in ways I couldn't think of
      
-h,m,s

      -h : hours
      
      set the number of hours for timer 
      
      -m : minutes
      
      set number of minutes for timer
      
      -s : seconds
      
      set number of seconds for timer
    
## Future Features

#### Cronjobber       
makes this script capable of launching and managing multiple alarms with the help of cron

#### MasterWaiter     
manages cronjobber, kills old alarms, prevents chaos, reduces resource usage organizationally

#### LaunchInWindow:   
launch gnome-terminal window for just the alarm. I will probably include a qt window as an alternative 

#### Snooze:
it snoozes the alarm. Not much to say here
