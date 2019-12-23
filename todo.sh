#!/bin/bash

############
# MVP v0.1 #
############

# initialize
if [ ! -d "./.todo/" ]; then
  mkdir .todo
fi
recentLine=0
cGreen="\e[92m"
cRed="\e[91m"
cReset="\e[39m"

# mark an item
function mark() {
  num="$1"
  symbol="$2"
  if [ "$num" == "" ]; then
    num="$recentLine"
  fi 
  sed -i "s/\[.*\]/\[$symbol\]/" .todo/list
}

case $1 in
  "add")
    # add item to list
    echo "[ ] $2" >> .todo/list
    
    # update the cursor to track the new recently added line
    fileLen=`wc -l todo.sh | awk '{print $1}'`
    recentLine="$fileLen"
    
    # update user
    echo " * added item to todolist"
    
    ;;
  "edit")
    # get the line number and text
    if [[ "$2" =~ ^[0-9]+$ ]]; then # check if its a number
      recentLine="$2"
      text="$3"
    else
      recentLine="$fileLen"
      text="$2"
    fi
    
    # select text
    textToEdit=`sed -n "$(echo $recentLine)p" .todo/list | sed "s/.*\[\(.*\)\] //"`
    
    # edit text
    sed -i "s/$textToEdit/$text/" ".todo/list"
    
    # update user
    echo -e " * changed line from \"$cRed$textToEdit$cReset\" to \"$cGreen$text$cReset\""
    ;;
  "complete")
    mark "$recentLine" "x"
    echo " * marked item completed"
    ;;
  "start")
    mark "$recentLine" "-"
    echo " * marked item as in-progress"
    ;;
  "list")
    cat .todo/list
    ;;
  *)
    echo -e "For more help see \"\e[92mtodo [add, complete, list] help\e[39m\". Go deeper!"
    ;;
esac
