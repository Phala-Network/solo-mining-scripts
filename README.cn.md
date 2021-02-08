### Phala安装脚本使用手册

[EN](./README.md) | 中文

#### 一、准备工作

-   #### 确认BIOS设置

    -   Secure Boot（安全启动） ，选择 Disabled（关闭）
    -   Boot Mode (启动模式) 里 启动 UEFI
    -   找到 SGX 选项，优先选 Enabled，如果没有则选 Software Controlled。

-   运行软件启动SGX程序并重启

```bash
sudo chmod +x sgx_enable
sudo ./sgx_enable
sudo reboot
```

#### 二、安装脚本

进入脚本文件拷贝的目录，执行以下命令

```bash
chmod +x install.sh
sudo ./install.sh cn
```

#### 三、使用方法

##### 3.1 安装部署

```bash
sudo phala install init
```

之后会要求配置节点名字、用户本地IP地址、controllor账户助记词

##### 3.2 启动挖矿程序

```bash
sudo phala start node
sudo phala start pruntime
sudo phala start phost
```
- start命令跟上debug可输出程序部署日志
```bash
sudo phala start node debug
sudo phala start pruntime debug
sudo phala start phost debug
```

##### 3.3 停止挖矿程序

```bash
sudo phala stop node
sudo phala stop pruntime
sudo phala stop phost
```

##### 3.4 更新程序

###### 3.4.1 仅更新

```bash
sudo phala update
```

###### 3.4.2 删库并更新

```bash
sudo phala update clean
```

###### 3.4.3 自动更新脚本

```bash
sudo phala update script
```

##### 3.5 检查三件套状态

```bash
sudo phala status
```

##### 3.6 输出各容器的日志

```bash
sudo phala logs node
sudo phala logs pruntime
sudo phala logs phost
```

##### 3.7 检查挖矿程序的配置信息

查看配置文件

```bash
sudo phala config show
```

配置节点

```bash
sudo phala config set
```

##### 3.8 运行自我诊断程序
- 使用phala安装命令，可不跟任何参数（将无需输入IP地址、账户助记词等）

```bash
sudo phala install
sudo phala sgx-test
```

#### 四、最简安装步骤

一台全新矿机配置步骤

1.运行sgx_enable软件开启SGX功能程序，然后重启
2.重启后依据安装手册，安装phala脚本
3.使用sudo phala install init命令部署挖矿程序，期间会配置你的节点名字、IP地址、controllor账户的助记词，配置结束后会等待一段时间
4.使用sudo phala start命令启动挖矿程序，挖矿程序启动结束后可以进行链上操作了
