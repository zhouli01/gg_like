#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
echo "..............git clone..............."
git clone  -b $3  git@git.kuaiduizuoye.com:fe/kdmisnew.git
echo ".............scp to rd ing..............."
scp -r /home/test/user/zhouli/Build/kdmisnew  rd@172.30.132.12:/home/rd/user/zhouli  >/dev/null
echo "...........rd 环境编译.+scp to test环境............"
echo -e "\033[42;34m ............................这里有点慢，稍等哈!!!................. \033[0m"
ssh rd@172.30.132.12 "cd /home/rd/user/zhouli/kdmisnew; sh build.sh >/dev/null;
scp -r /home/rd/user/zhouli/kdmisnew/output/kdmisnew.tar.gz test@172.30.132.12:/home/test; rm -rf /home/rd/user/zhouli/kdmisnew" 
echo ".............test 环境 tar解压.............同时清理test环境.."
ssh test@172.30.132.12  "cd /home/test ; tar -xf kdmisnew.tar.gz ; mv /home/test/kdmisnew.tar.gz /home/test/BAK;
rm -rf /home/test/user/zhouli/Build/kdmisnew"
