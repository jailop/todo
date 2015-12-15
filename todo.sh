#!/bin/sh

# Minimalist shell task manager

FILE=$HOME/.todo
TMP=/tmp/todo

if [ -z $1 ]
then
	grep -nTve "^[x|\?] " $FILE

# Tags query
# Search and sort keywords marked by an "@", these are tags
elif [ $1 = "tags" ]
then
	grep -oe '@[A-Za-z0-9]*' $FILE | sort -u

elif [ $1 = "timed" ]
then
	grep -nTve "^x " $FILE | egrep '[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort -k 2
# elif [ $1 = "add" ] && [ ! -z $2 ];
elif [ $1 = "add" ]
then
	echo "$2" >> $FILE
elif [ $1 = "maybe" ]
then
    if [ -z $2 ]
    then
        grep -nTe "^? " $FILE
    else
        sed "$2 s/.*/\? &/" < $FILE > $FILE~
	    cp $FILE~ $FILE
    fi
elif [ $1 = "update" ]
then
	sed "$2 s/.*/$3/" < $FILE > $FILE~
	cp $FILE~ $FILE

elif [ $1 = "done" ]
then
	TODAY=$(date)
	if [ -z $3 ]
	then
		sed "$2 s/.*/x & \[$TODAY\]/" < $FILE > $TMP
	else
		sed "$2 s/.*/x & ($3) \[$TODAY\]/" < $FILE > $TMP
	fi		
	cp $TMP $FILE

elif [ $1 = "compact" ]
then
	grep -ve "^x " $FILE > $FILE~
	cp $FILE~ $FILE
elif [ $1 = "promote" ]
then
	head -n $2 $FILE | tail -n 1 > /tmp/CURR.tmp
	head -n $(( $2 - 1 )) $FILE > /tmp/PREV.tmp
	tail -n +$(( $2 + 1 )) $FILE > /tmp/NEXT.tmp
	cat /tmp/CURR.tmp /tmp/PREV.tmp /tmp/NEXT.tmp > $FILE
elif [ $1 = "defer" ]
then
	head -n $2 $FILE | tail -n 1 > /tmp/CURR.tmp
	head -n $(( $2 - 1 )) $FILE > /tmp/PREV.tmp
	tail -n +$(( $2 + 1 )) $FILE > /tmp/NEXT.tmp
    cat /tmp/PREV.tmp /tmp/NEXT.tmp /tmp/CURR.tmp > $FILE
elif [ $1 = "top" ]
then
	if  [ -z $2 ]
	then
		grep -nTve "^[x|\?] " $FILE | head -n 5
	else
		grep -vTne "^[x|\?] " $FILE | grep -i $2 | head -n 5
	fi
elif [ $1 = "help" ]
then
	echo "todo - a minimalist task manager"
	echo "Usage:"
	echo "  todo [top] [PATTERN]  : show tasks optionally matching a pattern"
	echo "  todo add \"NEW_TASK\"   : add a new task to the list"
	echo "  todo done NUMBER [TIME] : mark a task as done"
	echo "  todo promote NUMBER   : the given task goes to the top"
	echo "  todo compact          : delete definetively the tasks done"
elif [ ! -z $1 ]
then
	grep -vTne "^[x|\?] " $FILE | grep -i $1
fi