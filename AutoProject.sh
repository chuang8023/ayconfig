#!/bin/bash
######脚本化私有云项目部署########
Cloud=$1
echo "请根据项目信息输入:"
echo "A：无忧私有云"
echo "B：物联网私有云"
echo "C：paas平台"
read $Cloud
case $Cloud in
"A")
	ProjectDir="safety"
	;;
"B")
	ProjectDir="iot"
	;;
"C")
	ProjectDir="paas"
	;;
esac

####safety
function BuildSafety () {
	echo "请确认项目访问方式"

}
