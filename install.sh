#!/bin/bash


INSTALL_ADD=http://www.winpcap.org/install/bin/WpcapSrc_4_1_3.zip
PACKAGE_NAME=$(echo $INSTALL_ADD | awk -F / '{print $NF}')
#检查 glibc-static gcc flex byacc 这3个rpm包是否安装
PackgeCheck() {
        rpm -q glibc-static gcc flex byacc || yum install -y glibc-static gcc flex byacc || echo "install faild" exit 2

}

#下载程序包
Packinstall() {
        #首先判断当前目录是否已经下载好文件,如果没有，才下载
        if [ ! -f ./$PACKAGE_NAME ]; then
                wget $INSTALL_ADD 
                echo $?
                [ $? != 0 ] && echo "DownLoad error!" && exit 2
        fi
        [ -d ./winpcap ] || unzip ./$PACKAGE_NAME #判断是否存在此文件夹  
}

Install_app () {
PackgeCheck     
#切换工作目录
cd /usr/local
Packinstall
cd /usr/local/winpcap/wpcap/libpcap
chmod +x configure runlex.sh
CFLAGS=-static ./configure
[ $? != 0 ] && echo "configure error" && exit 2
make
[ $? != 0 ] && echo "make error" && exit 2
cd rpcapd
make
[ $? != 0 ] && echo "make error " && exit 2 || 
rm -rf /usr/local/$PACKAGE_NAME
return 0
}
#启动程序
Startapp () {
  /usr/local/winpcap/wpcap/libpcap/rpcapd/rpcapd -n 
}


################################
if [ -f /usr/local/winpcap/wpcap/libpcap/rpcapd/rpcapd ]; then 
        Startapp
else
        Install_app
        [ $? != 0 ] && echo "unknow error" && exit 2
        Startapp

fi
