#!/bin/bash
######�ű���˽������Ŀ����########
Cloud=$1
echo "�������Ŀ��Ϣ����:"
echo "A������˽����"
echo "B��������˽����"
echo "C��paasƽ̨"
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
	echo "��ȷ����Ŀ���ʷ�ʽ"

}
