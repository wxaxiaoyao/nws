#!/bin/bash


main() {
	echo "请输入项目名..."
	read project_name
	if [ -z "$project_name" ]; then
		echo "项目名不能为空"
		return
	fi
	
	echo "创建web项目:$project_name"
	
	mkdir -p $project_name
	cd $project_name
	temp_dir=".temp"
	git clone git@github.com:wxaxiaoyao/nws.git $temp_dir
	# 拉取nws框架代码
	cp -fr $temp_dir/* .
	rm -fr $temp_dir
}

main $@
