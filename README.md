## Readme

EN | [中文](./README.cn.md)

#### Get to Ready

-   #### BIOS Setting

    -   Disabled Secure Boot
    -   Boot Mode must be **UEFI**
    -   SGX Setting，must be **Enabled** or **Software Controlled**

-   Run the **egx_enable** if your SGX setting in BIOS is  **Software Controlled**

```bash
sudo chmod +x sgx_enable
sudo ./sgx_enable
sudo reboot
```

#### Install the Phala Scripts

Go to the **Phala** folder

```bash
chmod +x install.sh
sudo ./install.sh
```

#### How to use

##### Install

```bash
sudo phala install init
```
Enter information as prompted.

##### Start minner
```bash
sudo phala start
```
##### Start docker separately
```bash
sudo phala start node
sudo phala start pruntime
sudo phala start phost
```

##### Stop minner
```bash
sudo phala stop
```
##### Stop docker separately
```bash
sudo phala stop node
sudo phala stop pruntime
sudo phala stop phost
```

##### Update Phala Dockers

###### Update Phala dockers without clean data

```bash
sudo phala update
```

###### Update Phala dockers with clean data

```bash
sudo phala update clean
```

##### Check the docker status

```bash
sudo phala status
```

##### Get Logs

```bash
sudo phala logs node
sudo phala logs pruntime
sudo phala logs phost
```

##### Check the cofig of minner


```bash
sudo phala config show
```
##### Setup the cofig of minner

```bash
sudo phala config set
```

##### Check the board support

```bash
sudo phala sgx-test
```

