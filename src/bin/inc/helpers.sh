#!/bin/bash
function array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

title() {
    local text pad

    (( ${#1} > 70 )) && { echo "$1"; return; }
    text=${1:+ }$1${1:+ }

    pad=$( eval "printf %.1s ={1..$(( ( 74 - ${#text} ) / 2 ))}" )

    echo "$pad$text$pad$( (( ${#text} % 2 )) && printf = )"
}

terminalColorClear='\033[0m'
terminalColorEmphasis='\033[1;32m'
terminalColorError='\033[1;31m'
terminalColorMessage='\033[1;33m'
terminalColorWarning='\033[1;34m'

echoDefault() {
    echo -e "${terminalColorClear}$1${terminalColorClear}"
}

echoMessage() {
    echo -e "${terminalColorMessage}$1${terminalColorClear}"
}

echoWarning() {
    echo -e "${terminalColorWarning}$1${terminalColorClear}"
}

echoError() {
    echo -e "${terminalColorError}$1${terminalColorClear}"
}

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'


echoSuccess() {
    echo -e "${GREEN}$1${NOCOLOR}"
}

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac


function str_replace(){
  if [ "$MACHINE" = "Mac" ]
  then
      sed -i='' "s|$1|$2|" "$STUB_DEPLOY_FILE_PATH"
      rm -rf $STUB_DEPLOY_FILE_PATH= # remove temporary file for Mac Os
  else
      sed -i "s|$1|$2|" "$STUB_DEPLOY_FILE_PATH"
  fi
}

function get_ignored_files_for_archive(){
  INGORED_FILES=''

  for archive_file in $ARCHIVE_INGORED_FILES
  do
    INGORED_FILES+="'$archive_file' "
  done

  for archive_folder in $ARCHIVE_INGORED_FOLDERS
  do
    INGORED_FILES+="'$archive_folder/*' "
  done

  while read line; do

      if [ -d $PROJECT_DIR/$line ]; then
        INGORED_FILES+="'${line:1}/*' " # remove first character for directory
      fi

      if [ -f $PROJECT_DIR/$line ]; then
        INGORED_FILES+="'$line' "
      fi

  done < "$PROJECT_DIR/.gitignore"

  echo "\"${INGORED_FILES}\""
}

function command_exists () {
    type "$1" &> /dev/null ;
}
