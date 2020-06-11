#!/bin/bash

###############################
# MVP v0.1 # Init  # 01/--/20 #
# REL v0.2 # Fixes # 06/11/20 #
###############################

# initialize
if [ ! -d "./.todo/" ]; then
  mkdir .todo
fi

cGreen="\e[92m"
cRed="\e[91m"
cReset="\e[39m"

# mark an item
function mark() {
  symbol="$2"

  if [ "$1" != "" ]; then
    recentLine="$1"
  fi
  
  sed -i "$(echo $recentLine)s/\[.*\]/\[$symbol\]/" .todo/list
  
  printLn ".*"
}

function printLn() {
  # take out comments
  formatted=$(nl -v 1 .todo/list | sed 's/--.*//')
  echo "$formatted" | sed -n "/\[$1\]/p"
}

case $1 in


  "add")
    # check if item exists in todo list
    if [ -f .todo/list ] && [ "$(grep "$2" .todo/list)" != "" ]; then
      similarText="$(grep "$2" .todo/list)"
      echo "Found similar lines, stopping:"
      grep "$2" .todo/list
    else
      # add item to list
      echo "[ ] $2" >> .todo/list
    
      # update the cursor to track the new recently added line
      fileLen=`wc -l .todo/list | awk '{print $1}'`
      recentLine="$fileLen"
    
      # update user
      nl .todo/list
      echo " * added item to todolist"
    fi
    ;;


  "list")
      case $2 in
	"-")
	  ;&
        "current")
          printLn "-"
       	  ;;
        "+")
	  echo "accepted but :( please use 'x' not '+'"
	  ;&
        "x")
	  ;&
        "done")
          printLn "x"
       	  ;;
	"all")
          printLn ".*"
	  ;;
	"help")
	  echo "todo list [-/current, +/x/done, all]"
	  ;;
	*)
          printLn "[ -]"
	  ;;
      esac
    ;;
  

  *)
    # NOTE for all following commands require a line number
    # Thus, make sure that a line number is specified (recentLine)
    [[ "$2" =~ ^[0-9]+$ ]] && recentLine=$2
    
    # get the line number from the user
    while [[ ! "$recentLine" =~ ^[0-9]+$ ]]
    do
      read -p "Please enter line number (recent not cached): " recentLine
    done
    ;;& # fallthrough that continues searching :D this makes me very happy
  

  "delete")
    if [[ "$2" =~ ^[0-9]+$ ]]; then
      recentLine=$2
      sed -i "$(echo $recentLine)d" .todo/list
      echo " * deleted line $recentLine"
      nl .todo/list
    else
      echo "Usage: delete [lineNumber]"
    fi
    ;;


  "edit")
    # get the line number and text
    if [[ "$2" =~ ^[0-9]+$ ]]; then
      text="$3"
    else
      text="$2"
    fi
    
    # select text
    textToEdit=`sed -n "$(echo $recentLine)p" .todo/list | sed "s/.*\[\(.*\)\] //"`
    
    # prompt the user if tno text was specified
    while [[ "$text" == "" ]]
    do
      sed -n "$(echo $recentLine)p" .todo/list
      read -p "Replace with text: " recentLine
    done
    

    # edit text
    sed -i "$(echo $recentLine)s/$textToEdit/$text/" .todo/list
    #sed -in "$(echo $recentLine)s/$textToEdit/$text/" .todo/list
    
    # update user
    echo -e " * changed line from \"$cRed$textToEdit$cReset\" to \"$cGreen$text$cReset\""
    printLn ".*"
    ;;
  
  
  "complete")
    mark "$recentLine" "x"
    echo " * marked item completed"
    ;;


  "start")
    mark "$recentLine" "-"
    echo " * marked item as in-progress"
    ;;


  "reset")
    mark "$recentLine" " "
    echo " * unmarked item"
    ;;
  

  *)
    echo -e "For more help see \"\e[92mtodo [list, add, edit, start, complete, reset, delete] help\e[39m\". Go deeper!"
    ;;


esac
