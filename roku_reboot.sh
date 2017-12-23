#!/bin/bash
#
# roku_reboot.sh restarts all roku devices on the local network by 
# finding each devices ip address, and then issuing a seuqence of 
# remote control commands to restart each roku 
#
# roku_reboot.sh runs on linux and requires nmap to be installed:
#    $ sudo apt-get install nmap
# 
# roku_reboot.sh requires all devices to contain the word Roku.
# On roku.com, in you Roku My Account, rename your Roku and include 
# the word Roku
#
# You can find the IP address of a Roku, by going to Settings, System, 
# About and get the IP address
#
# In Roku go to Settings, System, Control other devices and unclick 
# 1-touch play. Otherwise, when the Roku reboots inb the middle of the
# night it might wake up the people in the room
#
# In roku forums, Schmye Bubbula wrote something along the lines of:
#    Roku service reboot: Home 5x, Up, Rev 2x, Fwd 2x
#    Roku recommended a reboot using: Home 5x, Fwd, Play, Rev, Play, 
#       Fwd, Up 4x, Select, Up 5x, Select
#       However, I have had no luck getting either of the above to 
#       work. These commands seem to be time sensitive
#    Link: https://forums.roku.com/viewtopic.php?t=50985
#
# run using:
#       bash roku_reboot.sh 
#
# Create this file in /usr/bin/roku_reboot.sh: sudo nano /usr/bin/roku_reboot.sh
# Make it executable: sudo chmod +x /usr/bin/roku_reboot.sh
#
# restart all rokus via crontab running on a linux machine:
#	   # restart all of the rokus
#	   0 2 * * * bash /usr/bin/roku_reboot.sh 192.168.1.66 >/dev/null 2>&1
#
# The script below is from roku forums member schworak adapted from rrosamond's 
# earlier post
#   Link: https://forums.roku.com/viewtopic.php?t=55587
#
# Go to home menu and then record the key presses to restart the system
#   Home, Up, Right, Up, Right, Up, Up, Up, Right, Select
#
# I ran into problems if something is actually playing. So, I modified the
# original script to handle this.
#
# There is a complicated grep command to get all valid IP addresses in a string
# My network devices will always be 192.168.1.*. So, I simplified it
# The command puts the IP addresses in an array
# 
# nmap gets all devices on my network. grep Roku returns only roku devices. 
# grep 192 gives only valid Roku IP addresses
# and the final grep returns only the IP address, removing everything else in 
# the string and puts each IP address in an array

mapfile -t array < <(sudo nmap -sP 192.168.1.* | grep Roku | grep 192 | grep -oE "\b(192.168.1.?[0-9]?[0-9][0-9])\b")

# loop throught the array using one IP address at a time
for ip in "${array[@]}"; do
   # This sequence repeats the flow of a remote control doing a restart
   echo "Reboot roku with ip: $ip"

   # lengthening the sleep value causes the restart to fail
   # if something is being watched it takes longer to get to home
   # so go home and then do another command. Otherwise, the command sequence
   # isn't interpreted correctly. Wait for it to settle before doing the
   # restart sequence
   #
   # If communication with the device cannot be established, skip it and
   # go to the next IP address
   /usr/bin/curl -X POST -d "" http://$ip:8060/keypress/Home
   if [ "$?" != "0" ]; then echo "ERROR: roku connect and rboot failed: $ip"; continue; fi
   sleep 2.00
   curl -X POST -d "" http://$ip:8060/keypress/Up
   sleep 5.00

   # Now, try the restart resquence
   curl -X POST -d "" http://$ip:8060/keypress/Home
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Up
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Right
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Up
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Right
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Up
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Up
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Up
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Right
   sleep 0.35
   curl -X POST -d "" http://$ip:8060/keypress/Select
   sleep 0.35
done
