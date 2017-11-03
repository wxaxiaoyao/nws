#!/bin/bash


start_server(){
	npl -d nws/src/loader.lua
}

stop_server(){
	pid=`ps uax | grep -e "npl.*nws/src/loader" | grep -v grep | awk '{print $2}'`
	if [ ! -z $pid ]; then
		kill -9 $((pid))
	fi
}

restart_server(){
	stop_server
	start_server
}

main(){
	if [ "$1" == "start" ]; then
		echo "start webserver..."
		start_server
	elif [ "$1" == "stop" ]; then
		echo "stop webserver"...
		stop_server
	elif [ "$1" == "restart" ]; then
		echo "restart webserver..."
		restart_server
	else
		echo "restart webserver..."
		restart_server
	fi
}

main $@
