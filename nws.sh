#!/bin/bash


main() {
	if [ $# -lt 1 ]; then
		echo "请输入项目名..."
		return
	fi
	
	local project_name=$1
	
	# 拉取nws框架代码
	git clone git@github.com:wxaxiaoyao/nws.git $project_name
}



main $@
