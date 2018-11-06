#!/bin/bash
#author:zhouli 2018.02.03
#modify:zhouli 2018.03.29
#轻量级gg还有缺陷
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
PATH1="/home/test/user/zhouli/Build"
#PATH1=`pwd`
HOME="/home/test"
HOME1="/home/homework"

if [ $# -ne 4 ];then            #判断传参数量
    echo "Usage: $0 fe/scan master branch master/slave"
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

# 粉色打印
echo_purple()
{
        echo -e "\033[35;1m$1\033[0m"
}
value=     
#提醒注册
#echo_purple "请你先注册测试模块再开始测试....请你先注册测试模块再开始测试....请你先注册测试模块再开始测试...."
#echo $value
echo -e  "\033[46;30m ...................如果部署的是fe的kdmisnew模块,请执行b.sh脚本,格式同build.sh.................... \033[0m "

#注册测试模块
Record=`cat .mm/recording` 
echo_red "正在占用的模块分支:$Record"

#打印空格
echo $value

#$1的替换
if [ "$1" == fe ];then
    echo $2|sed -e 's/^/git@git.kuaiduizuoye.com:fe\//;s/$/\.git/'>tmp_1
elif [ "$1" == scan ];then
    echo $2|sed -e 's/^/git@git.kuaiduizuoye.com:scan\//;s/$/\.git/'>tmp_1
fi

if [ "$2" == "*" ];then
   echo_red "Please check  your  input" 
   exit 1 
else
  echo_purple  "Please  check  and check done"
fi


#$1 参数替换为master_git  ;$2参数就是分支
master_git=`cat tmp_1`
master_branch=$3
echo_red "模块master_git地址为：$master_git"
echo_red "分支branch为：$master_branch"
git clone -b $master_branch $master_git
echo_green "git clone  完毕啦！！！" 
#打日志的请忽略
echo_purple  "master_git is $master_git"
echo_purple  "master_branch is $master_branch"

#构建过程
cd $PATH1/$2 && sh build.sh 
cd $PATH1/$2/output 

if [ ! -f "$PATH1/$2/output/hk.tar.gz" ];then
    echo_green ".......七七八八的.........."
else
    echo_green ".....机器人启动超级变换..O(∩_∩)O哈哈~.............."
    mv hk.tar.gz $2.tar.gz 
fi

if [ -d "$PATH1/$2/output" ];then
    mv *.tar.gz $HOME
fi

if [ "$4" == slave ];then
#单独处理该脚本部署远程机器的问题
    echo_red "..............scp到远程机器，进行部署................"
    scp $HOME/$2.tar.gz  homework@172.30.128.11:$HOME1 >/dev/null 
    ssh homework@172.30.128.11 "tar -xzf  $2.tar.gz ; cd $HOME1 ; rm -rf $HOME1/$2.tar.gz " 
elif [ "$4" == master ];then
    #这里是为了加测试环境的mis后台登陆权限的
    #目前暂时没区分fe的kdmis和scan的kdmis 所以这里不做区分,但是涉及到MisUserBase接口的需要注意下
    echo_red ".......本机部署.........." 
    cd $HOME && tar -xzf  $2.tar.gz 
    cd $PATH1
    cp MisUserBase.php /home/test/app/kdmis/library/kdmis/action/
    #redis配置文件的端口号修改
    sed -i 's/5000/5500/g' /home/test/conf/hk/credis.conf
#清理文件
fi
cd $PATH1 && rm -rf $2 tmp_1 
cd $HOME  && rm -rf $2.tar.gz 
#构建完毕
echo_red "build is finished,please test!!!"      
