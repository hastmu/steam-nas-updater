#!/bin/bash

echo "Status: Work in Progress - no implemented function"

# defaults
declare -A CFG
CFG["cfg-root"]=~/.config/steam-nas-updater
CFG["cache-root"]=~/.cache/steam-nas-updater
CFG["bin-root"]=~/.local/steam-nas-updater

# ( echo "{" ; cat ~/Steam/steamapps/appmanifest_227300.acf ; echo "}" ) | tr "\n" "%" | sed 's/"%\s*{/": {/g' | tr "%" "\n" | sed 's/"\(.*\)"\s*"\(.*\)"/"\1": "\2"/g' | tr "\n" "%" | sed 's/"%\s*"/",% "/g' | sed 's/}%\s*"/},% "/g' | tr "%"  "\n" | jq

export PATH=${PATH}:${CFG["bin-root"]}/bin

[ ! -x "${CFG["cfg-root"]}" ] && mkdir -p "${CFG["cfg-root"]}"
[ ! -x "${CFG["cache-root"]}" ] && mkdir -p "${CFG["cache-root"]}"
[ ! -x "${CFG["bin-root"]}/bin" ] && mkdir -p "${CFG["bin-root"]}/bin"

declare -A BINS
declare -A bin=( ["curlx"]="Please install via distribution" ["tar"]="Please install via distribution" ["jq"]="Please install via distribution" ["git"]="Please install via distribution" ["steamcmd.sh"]="-" ["acf_to_json"]="-" )

function file_age() {
	if [ ! -e "$1" ]
	then
	   return 1
	else
		local age=$(( $(date +%s) - $(stat -c %Y "$1") ))
		if [ -z "$2" ]
		then
		  echo "${age}"
		else
		  if [ ${age} -gt $2 ]
		  then
			 return 1
		  else
			 return 0
		  fi
		fi
	fi
}

function steamcmd_fetch_updateinfo() {
	
	if file_age "${CFG["cache-root"]}/$1.acf" 600
	then
		cat "${CFG["cache-root"]}/$1.acf.asc" 
	else
		steamcmd.sh +login anonymous +app_info_update 1 +app_info_print $1 +quit \
		| awk 'BEGIN { a=0 } /AppID/ { a=1 ; next } { if( a == 1 ) print $0 }' > "${CFG["cache-root"]}/$1.acf"
		#file "${CFG["cache-root"]}/$1.acf" >&2
		iconv -c -f UTF-8 -t ASCII -o "${CFG["cache-root"]}/$1.acf.asc" "${CFG["cache-root"]}/$1.acf" 
		cat "${CFG["cache-root"]}/$1.acf.asc" 
	fi
	
}

function acf2json() {
   ( echo "{" ; cat $1 ; echo "}" ) \
   | tr "%" "@" \
   | tr "\n" "%" \
   | sed 's/"%\s*{/": {/g' \
   | tr "%" "\n" \
   | sed 's/"\(.*\)"\s*"\(.*\)"/"\1": "\2"/g' \
   | tr "\n" "%" \
   | sed 's/"%\s*"/",% "/g' \
   | sed 's/}%\s*"/},% "/g' \
   | tr "%"  "\n"
}

function install_steamcmd.sh() {
   echo "install steamcmd"
   cd ${CFG["bin-root"]}/bin
   curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
   cd
   steamcmd.sh +quit
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

   # PoC update stuff
   echo "POC-Warning: I assume you have a working steamcmd and acf_to_json up and running"
   if [ -z "${steam_account}" ]
   then
      echo "POC-FATAL: set steam_account to your steam account name."
      exit 1
   fi
   cd 

   # filter
   [ -z "$2" ] && FILTER=".*" || FILTER="$2"
   echo "FILTER: ${FILTER}"

for item in $(find Steam/steamapps/. -maxdepth 1 -type f -name "*.acf" -printf "%f\n" | grep "${FILTER}" )
do
   #echo "item: ${item}"
   #acf_to_json Steam/steamapps/${item} | jq '.AppState'
   appid=$(acf2json Steam/steamapps/${item} 2>>/dev/null | jq -r '.AppState.appid') 
   name=$(acf2json Steam/steamapps/${item} 2>>/dev/null | jq -r '.AppState.name') 
   buildid=$(acf2json Steam/steamapps/${item} 2>>/dev/null | jq -r '.AppState.buildid') 
   f_buildid=$(steamcmd_fetch_updateinfo ${appid} \
               | acf2json | jq -r ".\"${appid}\".depots.branches.public.buildid")
   printf "%40s [%10s] %s -> %s\n" "${name}" "${appid}" "${buildid}" "${f_buildid}"
   [ -e ${CFG["cfg-root"]}/.steam_${appid}_${f_buildid} ] && continue
   [ "x${buildid}" = "x${f_buildid}" ] && continue
   [ -z "${buildid}" ] && continue
   [ -z "${f_buildid}" ] && continue
   steamcmd.sh +login ${steam_account}  +@sSteamCmdForcePlatformType windows +app_update ${appid} validate +quit
   if [ $? -eq 0 ]
   then
      touch ${CFG["cfg-root"]}/.steam_${appid}_${buildid}
   fi
done

} ;;

*) {
   echo "help: $0 [install|setup|update-lib]"
   exit 1
} ;;

esac


