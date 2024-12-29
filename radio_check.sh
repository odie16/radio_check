#!/bin/bash

# Můj první trošku složitější skript! Začátek března 2023.
# v0.2 - opraveno pomocí ChatGPT v.3 :D
# 
# Kontroluje, jestli rádia, které mám uložené v záložkách radiotray-ng, jsou stále online.
# Až to budeš za pár let číst, budoucí Odie, odpusť mi, vždyť nevím, co činím.
# 
# TODO
# -[] Ve fci CheckRadios: uložit $name a $url do array a udělat cyklus
# -[] Ukládat stanice zemí.
# -[] Možnost použití jiného přehrávače než mpv.
# DONE
# -[x] Při použití platného přepínače spustit skript neinteraktivně.

# Uživatelská nastavení
interactive=yes
mpv_play=no
mpv_wait=10 # jak dlouho bude mpv čekat - normálně 10 sekund
path_to_dir=$HOME/Agenda/vzdělání/IT/rádia # cesta k adresáři pro uložení výstupu

# Deklarace proměnných, úvodní záležitosti.
currentdatetime=$(date '+%Y-%m-%d_%Hh-%Mm-%Ss') # uložíme dnešní datum a čas spuštění
path_to_file=$path_to_dir/stations_FAIL_$currentdatetime.txt
path_to_bookmarks=$HOME/.config/radiotray-ng/bookmarks.json # cesta k záložkám radiotray-ng

# nápověda
function Help {
  echo "'radio_check2.sh' HELP PAGE"
  echo
  echo "This script checks urls saved in radiotray-ng bookmarks using ffprobe. It can simultaneously play them for a specified # of seconds with mpv (media player).
  #echo
  #echo "Output is saved by default to \$HOME ($HOME). Can be changed by modifying the variable path_to_dir (current: $path_to_dir)."
  #echo  
  #echo "Run without parameters to simply check radios availability."
  echo
  echo "Usage: radiocheck.sh [options] (Interactive mode by default!)"
  echo "-c              Check the radios."
  echo "-p              Play the radios while checking."
  echo "-t seconds      Let mpv stay for specified number of seconds (default=3). Useful for slow connections, or with -p."
  echo "-h              Display this help."
}

# přepínače
while getopts "cpht:" opt; do
  case "${opt}" in
    c)  interactive=no ;;
    p)  mpv_play=yes
        echo "If the stream is up, the station will play for ${mpv_wait} seconds." ;;
    h)  Help; exit 1 ;;
    t)  if [[ ${OPTARG} =~ ^[0-9]+$ ]]; then
          mpv_wait=${OPTARG}
          echo "mpv will wait $mpv_wait seconds."
        else
          echo "Input is not a number." >&2
          exit 1
        fi ;;
    *)  echo "Error in command line parsing." >&2
        exit 1 ;;
  esac
done

# hlavní funkce
function CheckRadios {
  cat $path_to_bookmarks | jq '.[].stations' | jq -r '.[] | .name, .url' | sed 'N;s/\n/|/'\ |\
  while read station
  do
    name=$(echo $station | sed 's/\(.*\)|\(.*\)$/\1/') # uložení názvu stanice
    url=$(echo $station | sed 's/\(.*\)|\(.*\)$/\2/') # uložení adresy stanice
    echo "checking:"
    echo $name
    echo $url

  # Zkontrolujeme adresy s použitím ffprobe.
    if ffprobe -v quiet -show_format -show_streams "$url" | grep -q "codec_type=audio"; then
      echo "$name is still online."
      # Když si chceme právě kontrolovaná rádia u toho poslechnout
      if [[ $mpv_play == "yes" ]]; then
        timeout $mpv_wait mpv "$url" &&
        return
      fi
    else
      echo "$name is no longer online."
      # uloží název a adresu stanice
      echo -e "$name \n$url\n" >> $path_to_file
    fi
  done
  echo "done"
  return 0
}

# interaktivní část
if [[ $interactive == yes ]]; then
  read -p "Do you want to run this script now? (y/n/h): " answer
  case $answer in
    [Yy] ) CheckRadios && exit ;;
    [Nn] ) echo "Exiting…" && exit ;;
    [Hh] ) Help && exit ;;
    * ) echo "-> Please answer yes or no (y/n), or see help (h)." && exit;;
  esac
fi

CheckRadios

exit