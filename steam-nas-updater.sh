#!/bin/bash

echo "Status: Work in Progress - no implemented function"

declare -A BINS
declare -a bin=( "steamcmd" "acf_to_json" "ls" )

function install() {
   # dependencies: steamcmd, acf_to_json
   # return 0 if all fine otherwise install or return non-zero
   
   # check if we are good to go...
   local item=""
   local ret=0
   for item in ${bin[@]}
   do
      BINS[${item}]="$(which ${item})"
      [ -z "${BINS[${item}]}" ] && ret=1
   done
   
   # if not try to install
   if [ $ret -ne 0 ]
   then
      echo "try install..."
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


