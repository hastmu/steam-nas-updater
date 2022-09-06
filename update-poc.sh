#!/bin/bash
steam_account="tbu"

for item in $(find Steam/steamapps/. -maxdepth 1 -type f -name "*.acf" -printf "%f\n")
do
   #echo "item: ${item}"
   #acf_to_json Steam/steamapps/${item} | jq '.AppState'
   appid=$(acf_to_json Steam/steamapps/${item} 2>>/dev/null | jq -r '.AppState.appid') 
   name=$(acf_to_json Steam/steamapps/${item} 2>>/dev/null | jq -r '.AppState.name') 
   buildid=$(acf_to_json Steam/steamapps/${item} 2>>/dev/null | jq -r '.AppState.buildid') 
   f_buildid=$(steamcmd.sh +login anonymous +app_info_update 1 +app_info_print ${appid} +quit | acf_to_json | jq -r ".\"${appid}\".depots.branches.public.buildid")
   printf "%40s [%10s] %s -> %s\n" "${name}" "${appid}" "${buildid}" "${f_buildid}"
   [ -e .steam_${appid}_${f_buildid} ] && continue
   [ "x${buildid}" = "x${f_buildid}" ] && continue
   [ -z "${buildid}" ] && continue
   [ -z "${f_buildid}" ] && continue
   steamcmd.sh +login ${steam_account}  +@sSteamCmdForcePlatformType windows +app_update ${appid} validate +quit
   if [ $? -eq 0 ]
   then
      touch .steam_${appid}_${buildid}
   fi
done

