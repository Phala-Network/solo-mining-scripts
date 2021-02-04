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
sudo ./install.sh en
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
- Use debug parameter to output command logs
```bash
sudo phala start node debug
sudo phala start pruntime debug
sudo phala start phost debug
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

##### Check the config of minner


```bash
sudo phala config show
```
##### Setup the config of minner

```bash
sudo phala config set
```

##### Check the board support
- Use `sudo phala install` command to install all dependencies witout configuration

```bash
sudo phala sgx-test
```

