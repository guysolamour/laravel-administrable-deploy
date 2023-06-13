#!/bin/bash
#------------------------------------------------------------------------------------------------------------------------------>
#  Display this help (all commands and descriptions)
#------------------------------------------------------------------------------------------------------------------------------>
# Display display_help
echo "Laravel deployment system built with ansible & ansistrano."
echo "Available commands are:"

for item in ${ALL_COMMANDS[@]}; do
  echo "\$_ $item"
done

exit 1
