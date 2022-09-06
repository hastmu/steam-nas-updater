#!/bin/bash

echo "Status: Work in Progress - no implemented function"

case "$1"
in

install) {
   echo "this will install all needed dependencies"

} ;;

setup) {
   echo "this will support you in setting up steamcmd and the steamlibrary"

} ;;

update-lib) {
   echo "this will run the update."

} ;;

*) {
   echo "help: $0 [install|setup|update-lib]"
   exit 1
} ;;

esac


