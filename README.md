EN | [中文](./README.cn.md)

<p align="center">
  <a href="https://phala.network/">
    <img alt="Phala Network" src="https://avatars.githubusercontent.com/u/59632547?s=200&v=4" width="60">
  </a>
</p>


<h1 align="center">
  Phala Mining Script
</h1>

## Navigate
- [Before Getting Started](#before-getting-started)
  - [BIOS & SGX](#bios-settings)
    - [Mainboard](#check-if-mainboard-is-supported)
- [Install the Phala Scripts](#install-the-phala-scripts)   
 - [How to Use the Script](#script-usage)
    - [Getting your Machine's Scores](#get-the-scores-of-your-machine)
    - [Start the Miner](#start-the-miner)
    - [Stop the Miner](#stop-the-miner)
    - [Get Logs](#get-logs)
    - [Miner Status Check](#check-the-miners-status)
    - [Update the Phala Miner Script](#update-the-script)
    - [Docker :whale:](#stop-the-miner)
        - [Starting Phala Docker Containers Separately](#start-docker-separately)
        - [Stopping Phala Docker Containers Separately](#stop-docker-separately)


## Instructions

#### Before Getting Started

> * Check at [Intel Ark](https://ark.intel.com/content/www/us/en/ark.html#@Processors) that your processor is [Intel SGX](https://www.intel.com/content/www/us/en/developer/tools/software-guard-extensions/overview.html) compatible.
> 
> * Have [Ubuntu 18.04](https://releases.ubuntu.com/18.04/), [Ubuntu 20.04](https://releases.ubuntu.com/20.04/) or [Ubuntu 21.04](https://releases.ubuntu.com/21.04/) installed. Compatible kernel versions may vary.

-   #### BIOS Settings

    -   Disable Secure Boot
    -   Boot Mode must be **UEFI**
    -   SGX Settings must be **Enabled** or **Software Controlled**

- Download the Script

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install wget unzip
cd ~
wget https://github.com/Phala-Network/solo-mining-scripts/archive/refs/heads/main.zip
unzip main.zip
```

-   Run the **egx_enable** if your SGX setting in BIOS is **Software Controlled**

```bash
sudo chmod +x sgx_enable
sudo ./sgx_enable
sudo reboot
```

-   #### Check if Mainboard is Supported
    - Use the `sudo phala install` command to install all dependencies without their configuration

    ```bash
    sudo phala sgx-test
    ```

#### Install the Phala Scripts

Go to the **Phala** folder

```bash
chmod +x install.sh
sudo ./install.sh en
```

#### Get the Scores of your Machine 

Note: The number of cores depends on your machine.

```bash
sudo phala score_test [the number of your cores]
```

##### Get Logs

```bash
sudo phala logs node
sudo phala logs pruntime
sudo phala logs pherry
```

##### Check the Configuration of the Miner

```bash
sudo phala config show
```

###### Update the Script

```bash
sudo phala update script
```

#### Script Usage

##### Installation

```bash
sudo phala install init
```
Enter your information as prompted.

##### Miner Configuration

```bash
sudo phala config set
```

##### Start the Miner

```bash
sudo phala start
```

##### Stop the Miner
```bash
sudo phala stop
```

##### Check the Miner's Status

```bash
sudo phala status
```

#### Phala & Docker 🐳

##### Start Docker Separately

```bash
sudo phala start node
sudo phala start pruntime
sudo phala start pherry
```

- Use debug parameter to output command logs
```bash
sudo phala start node debug
sudo phala start pruntime debug
sudo phala start pherry debug
```

##### Stop Docker Separately
```bash
sudo phala stop node
sudo phala stop pruntime
sudo phala stop pherry
```

##### Update Phala Docker Containers

###### Update Phala Dockers Without Clean Data

```bash
sudo phala update
```

###### Update Phala Docker Images with Clean Data

```bash
sudo phala update clean
```
