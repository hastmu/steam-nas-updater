#!/bin/bash

echo "Status: Work in Progress - no implemented function"

# defaults
declare -A CFG
CFG["cfg-root"]=~/.config/steam-nas-updater
CFG["bin-root"]=~/.local/steam-nas-updater

[ ! -x "${CFG["cfg-root"]}" ] && mkdir -p ${CFG[cfg-root]}
[ ! -x "${CFG["bin-root"]}" ] && mkdir -p ${CFG[bin-root]}

declare -A BINS
declare -A bin=( ["curlx"]="Please install via distribution" ["tar"]="Please install via distribution" ["jq"]="Please install via distribution" ["git"]="Please install via distribution" ["steamcmd"]="-" ["acf_to_json"]="-" )
declare -A

function install_steamcmd() {
   echo "install steamcmd"
   #curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
}

function install_acf_to_json() {
   echo "install acf_to_json"
}

function install() {
   # dependencies: steamcmd, acf_to_json
   # return 0 if all fine otherwise install or return non-zero
   
   # check if we are good to go...
   local item=""
   local ret=0
   for item in ${!bin[@]}
   do
      BINS[${item}]="$(which ${item})"
      [ -z "${BINS[${item}]}" ] && ret=1
   done
   
   # if not try to install
   if [ $ret -ne 0 ]
   then
      echo "try install..."
      for item in ${!bin[@]}
      do
	 if [ -z "${BINS[${item}]}" ]
	 then
	    echo "- not found: ${item}"
	    if [ "x$(LC_ALL=C type -t install_${item})" = "xfunction" ]
	    then
	       install_${item}
	    else
	       echo "${bin[${item}]}"
	    fi
	 fi
      done
   fi
   
   # feedback final status
   return ${ret}
}

case "$1"
in

install) {
   echo "this will install all needed dependencies"
   install
} ;;

setup) {
   echo "this will support you in setting up steamcmd and the steamlibrary"

} ;;

update-lib) {
   echo "this will run the update."
   if install
   then
      echo "install ok"
      declare -p BINS
   else
      echo "install broken"
      declare -p BINS
   fi
} ;;

*) {
   echo "help: $0 [install|setup|update-lib]"
   exit 1
} ;;

esac


