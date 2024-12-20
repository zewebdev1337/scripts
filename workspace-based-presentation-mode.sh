#!/bin/bash

# make sure that only one instance of this script is running per user
lockfile=/tmp/.wchg.$USER.lockfile
if ( set -o noclobber; echo "locked" > "$lockfile") 2> /dev/null; then
   trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
   echo "Workspace monitor: Locking succeeded" >&2

   CURRENT_WORKSPACE=$(wmctrl -d | grep \* | cut -d' ' -f1)
   while true
   do
      sleep 1
      NEW_WORKSPACE=$(wmctrl -d | grep \* | cut -d' ' -f1)
      if [ $CURRENT_WORKSPACE -ne $NEW_WORKSPACE ]; then 
         echo "A workspace change has occurred. $CURRENT_WORKSPACE -> $NEW_WORKSPACE"
         
         # Toggle presentation mode based on workspace
         if [ $NEW_WORKSPACE -eq 0 ]; then
            xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -s false
            echo "Presentation mode disabled"
         elif [ $NEW_WORKSPACE -eq 1 ]; then
            xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -s true
            echo "Presentation mode enabled"
         fi
         
         CURRENT_WORKSPACE=$NEW_WORKSPACE
      fi
   done

else
   echo "Workspace monitor: Lock failed, check for existing process and/or lock file and delete - exiting." >&2
   exit 1
fi

exit 0
