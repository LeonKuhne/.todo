#!/bin/bash

############
# MVP v0.1 #
############

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
      fileLen=`wc -l ~/.todo/todo.sh | awk '{print $1}'`
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
          nl .todo/list | sed -n '/\[-\]/p'
       	  ;;
        "x")
	  ;&
        "done")
          nl .todo/list | sed -n '/\[x\]/p'
       	  ;;
	"all")
          nl .todo/list
	  ;;
        *)
		nl .todo/list | sed -n '/\[[ -]\]/p'
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
    textToEdit=`sed -n "$(echo $recentLine)p" .todo/list | sed "s/.*\[\(.*\)\]//"`
    
    echo "$textToEdit"
    # edit text
    sed -i "$(echo $recentLine)s/$textToEdit/$text/" .todo/list
    #sed -in "$(echo $recentLine)s/$textToEdit/$text/" .todo/list
    
    # update user
    echo -e " * changed line from \"$cRed$textToEdit$cReset\" to \"$cGreen$text$cReset\""
    nl .todo/list
    ;;
  
  
  "complete")
    mark "$recentLine" "x"
    echo " * marked item completed"
    nl .todo/list
    ;;


  "start")
    mark "$recentLine" "-"
    echo " * marked item as in-progress"
    nl .todo/list
    ;;


  "reset")
    mark "$recentLine" " "
    echo " * unmarked item"
    nl .todo/list
    ;;
  

  *)
    echo -e "For more help see \"\e[92mtodo [add, complete, list] help\e[39m\". Go deeper!"
    ;;


esac
