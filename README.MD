
## 打包脚本使用方法
-  1. 首先需要验证ipa是否砸壳
 -  otool -l xxx.app/xxx | grep -B 2 crypt
  - 0为解密 1位加密 ， 加密的包即使重签名成功也会安装到手机上也会导致闪退
  - 2. 证书配置
  -  需要配置cer
   - 需要配置provisioning Profiles
    - 如果是安装到测试机器需要使用adhoc证书
    - 发布则使用发布证书
    
# 欢迎指正
    
