#!/bin/bash
#author:zhouli 2018.02.03
#modify:zhouli 2018.03.29
#轻量级gg还有缺陷
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
PATH1="/home/test/user/zhouli/Build"
HOME="/home/test"
if [ $# -ne 2];then            #判断传参数量
    echo "Usage: $0 master branch"
    exit
fi

# 红色打印
echo_red()
{   
    while [ "$1" != "" ];do
        echo -e "\033[31;1m$1\033[0m"
        shift
    done
}

# 绿色打印
echo_green()
{
    while [ "$1" != "" ];do
        echo -e "\033[32;1m$1\033[0m"
        shift
    done
}
#$1的替换,太low了，你忽略
tmp=`echo $1`
echo $tmp>tmp_1
sed -i  's/^/\//'  tmp_1 
sed -i 's/^/git@git.kuaiduizuoye.com:scan/' tmp_1
sed -i 's/$/\.git/' tmp_1

#$1 参数替换为master_git  ;$2参数就是分支
master_git=`cat tmp_1`
master_branch=$2
echo_red "模块master_git地址为：$master_git"
echo_red "分支branch为：$master_branch"
git clone  $master_git $master_branch

#打日志的请忽略
echo_green  "master_git is $master_git"
echo_green  "master_branch is $master_branch"



#构建过程
cd $PATH1/$master_branch && sh build.sh sleep 10 && cd $PATH1/$master_branch/output 

if [ ! -f "$PATH1/$master_branch/output/hk.tar.gz" ];then
    echo_green ".......七七八八的bug.........."
else
    echo_green ".....机器人启动超级变换..O(∩_∩)O哈哈~.............."
    mv hk.tar.gz $1.tar.gz 
fi

mv * $HOME && cd $HOME && tar -xzvf  $1.tar.gz >/dev/null
   
#构建完毕
echo_green "build is finished,please test!!!" 


#这里是为了加测试环境的mis后台登陆权限的
#目前暂时没区分fe的kdmis和scan的kdmis 所以这里不做区分,但是涉及到MisUserBase接口的需要注意下
cd $PATH1
cp MisUserBase.php /home/test/app/kdmis/library/kdmis/action/


#清理文件
cd $PATH1 && rm -rf $master_branch 
cd $HOME  && rm -rf $1.tar.gz 
