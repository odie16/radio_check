# radio_check.sh

A bash script that checks urls saved in radiotray-ng bookmarks using ffprobe. It can simultaneously play them for a specified # of seconds with mpv (media player).

Output is saved by default to \$HOME ($HOME). Can be changed by modifying the variable path_to_dir (current: $path_to_dir)."
  
Run without parameters to simply check radios availability.

Usage: radiocheck.sh [options] (Interactive mode by default!)"
-c              Check the radios."
-p              Play the radios while checking."
-t seconds      Let mpv stay for specified number of seconds (default=3). Useful for slow connections, or with -p."
-h              Display this help."