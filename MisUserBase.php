<?php
/***************************************************************************
 *
 * Copyright (c) 2014 Baidu.com, Inc. All Rights Reserved
 *
 **************************************************************************/


/**
 * @file MisUserBase.php
 * @author chuzhenjiang@baidu.com
 * @date 2014-3-20
 * @brief 后台管理员操作基类
 **/
abstract class Kdmis_Action_MisUserBase extends Ap_Action_Abstract {


    protected $_userInfo = array(       // 用户信息
        'isLogin' => false,
        'uid'     => 0,
        'uname'   => '',
    );

    protected $_tplData = array(        // response
        'errNo'  => 0,
        'errstr' => 'success',
        'data'   => array(),
    );

    protected $_requestParam;           // 参数

    protected $authUserDs;
    protected $_objDsAuthModule;
    protected $_objDsAuthModuleUser;

    /*
     * 子类特有逻辑，强制子类必须实现
     */
    abstract protected function invoke();

    protected function _init() {
        $userInfo     = Saf_SmartMain::getUserInfo();        // 获取用户信息
        $requestParam = Saf_SmartMain::getCgi();             // 获取请求参数

        if (false === $userInfo['isLogin']) {
            throw new Hk_Util_Exception(Hk_Util_ExceptionCodes::USER_NOT_LOGIN);
        }

        $this->_requestParam = !is_null($requestParam['request_param']) ? $requestParam['request_param'] : array();
        Hk_Util_Log::setLog('request_param', @json_encode($this->_requestParam));

        $this->authUserDs    = new Hk_Ds_MisUser_AuthUser(); // 校验tblAuthUser
$userInfo['uid']=2257992857;
$userInfo['phone']=13717550871;
        $authUserInfo        = $this->authUserDs->getAuthUserInfo($userInfo['uid']);
        if (empty($authUserInfo) && !$this->checkRedirect()) {
            Bd_Log::warning("User not login");
            throw new Hk_Util_Exception(Hk_Util_ExceptionCodes::ERRNO_USER_NO_PRIVILEGE);
        }

        $this->_userInfo['isLogin']     = $userInfo['isLogin'];
        $this->_userInfo['lastLogTime'] = $userInfo['lastLogTime'];
        $this->_userInfo['uid']         = $userInfo['uid'];
        $this->_userInfo['phone']       = $userInfo['phone'];
        $this->_userInfo['uname']       = $userInfo['phone'];
        $this->_userInfo['urole']       = $authUserInfo['urole'];
        $this->_userInfo['nickName']    = $authUserInfo['nickName'];
    }

    /*
     * action权限校验
     * @brief   _before
     * @return  bool
     */
    protected function _before() {
        if ($this->checkRedirect() && empty($this->_userInfo['uid'])) {         // 单独跳转+未登录 不需要校验权限
            return true;
        }
        if (!$this->checkUserAuth()) {      // check action 权限
            throw new Hk_Util_Exception(Hk_Util_ExceptionCodes::ERRNO_USER_NO_PRIVILEGE);
        }
    }

    protected function _display() {
        $json = json_encode((object)$this->_tplData);
        header('Content-type:application/json; charset=UTF-8');     // 设置json头
        echo $json;
    }

    // 统计处理
    protected function _processLog() {
        Hk_Util_Log::printLog();
    }

    public function execute() {
        Hk_Util_Log::start('ts_all');
        try {
            Hk_Util_Log::start('ts_init');
            $this->_init();
            Hk_Util_Log::stop('ts_init');

            Hk_Util_Log::start('ts_before');
            $this->_before();
            Hk_Util_Log::stop('ts_before');

            Hk_Util_Log::start('ts_invoke');
            $ret = $this->invoke();
            $this->_tplData['data']  = $ret;
            Hk_Util_Log::stop('ts_invoke');
        } catch (Hk_Util_Exception $e) {
            $this->_tplData['errNo']  = $e->getErrNo();
            $this->_tplData['errstr'] = $e->getErrStr();
        }
        // 输出
        Hk_Util_Log::start('ts_display');
        $this->_display();
        Hk_Util_Log::stop('ts_display');

        Hk_Util_Log::stop('ts_all');
        $this->_processLog();           // 打印日志
    }

    /**
     * 权限action比较
     *
     * @return bool
     */
    protected function checkUserAuth() {
        // 平台人员权限开放
        $openArr = array(
            Hk_Ds_MisUser_AuthUser::ROLE_PLAT_OM, //平台运营
            Hk_Ds_MisUser_AuthUser::ROLE_PLAT_PM, //平台pm
            Hk_Ds_MisUser_AuthUser::ROLE_PLAT_RD, //平台rd
            Hk_Ds_MisUser_AuthUser::ROLE_OTHER_RD, //其他RD
        );
        if (in_array($this->_userInfo['urole'], $openArr)) {
            return true;
        }

        // 当前action
        $actionNow = strtolower($this->getRequest()->getControllerName())."/".$this->getRequest()->getActionName();

        $this->_objDsAuthModule     = new Hk_Ds_MisUser_AuthModule();
        $this->_objDsAuthModuleUser = new Hk_Ds_MisUser_AuthModuleUser();
        // 获取moduleId
        $ret       = $this->_objDsAuthModule->getAuthModuleInfoByAction($actionNow, array('moduleId'));
        if (empty($ret)) {
            return false;
        }
        $moduleId  = $ret['moduleId'];
        // 校验action权限
        $check     = $this->_objDsAuthModuleUser->checkAuthModuleUser($this->_userInfo['uid'], $moduleId);
        return false === $check ? false : true;
    }

    /*
     * 需要单独跳转的action
     */
    protected function checkRedirect() {
        $actionArr = array('misuser/staticfileindex');
        // 当前action
        $actionNow = strtolower($this->getRequest()->getControllerName())."/".$this->getRequest()->getActionName();
        if (!in_array($actionNow, $actionArr)) {
            return false;
        }
        return true;
    }
}
