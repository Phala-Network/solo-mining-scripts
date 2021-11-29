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
    - [:raising_hand_man: Troubleshooting](#troubleshooting)
        - ['Failed to install the DCAP driver'](#failed-to-install-the-dcap-driver)
        - [Khala Node Stops Synching](#khala-node-stops-synching)

## Instructions

#### Before Getting Started

> * Check at [Intel© Ark](https://ark.intel.com/content/www/us/en/ark.html#@Processors) that your processor is [Intel© SGX](https://www.intel.com/content/www/us/en/developer/tools/software-guard-extensions/overview.html) compatible.
> 
> * Have [Ubuntu 18.04](https://releases.ubuntu.com/18.04/), [Ubuntu 20.04](https://releases.ubuntu.com/20.04/) or [Ubuntu 21.04](https://releases.ubuntu.com/21.04/) installed. Compatible kernel versions may vary.

-   #### BIOS Settings

    -   Disable Secure Boot
    -   Boot Mode must be **UEFI**
    -   Intel© SGX Settings must be **Enabled** or **Software Controlled**

- Download the Script

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install wget unzip
cd ~
wget https://github.com/Phala-Network/solo-mining-scripts/archive/refs/heads/main.zip
unzip main.zip
rm -r main.zip #cleaning up the installation
```

-   Run the **egx_enable** if your SGX setting in BIOS is **Software Controlled**

```bash
cd solo-mining-scripts-main/ #note this depends on your current directory
sudo chmod +x sgx_enable
sudo ./sgx_enable
```

It is now recommended to reboot you machine. 

```bash
sudo reboot
```

    
<h1 align="center">
</h1>

#### Install the Phala Scripts

Go to the **Phala** folder

```bash
cd solo-mining-scripts-main/ #note this depends on your current directory
chmod +x install.sh
sudo ./install.sh en
```

-   #### Check if Mainboard is Supported
    - Use the `sudo phala install` command to install all dependencies without their configuration

    ```bash
    sudo phala sgx-test
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

<h1 align="center">
</h1>

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

<h1 align="center">
</h1>

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

<h1 align="center">
</h1>

## :raising_hand_woman::raising_hand_man:

#### Troubleshooting

Most symptoms are solved by restarting your node. If you experience issues running your node, try stopping the node by:

```bash
sudo phala stop
```

And attempt a restart with 
```bash
sudo phala start
```

If you still have issues attempt to [update the script](#update-the-script).

##### Advanced Troubleshooting 

In some cases, it might be beter to reinstall the mining script. 
To do this, first uninstall the script: 

```bash
sudo phala uninstall
```

And delete the mining script repository by executing:

```bash
yes | sudo rm -r solo-mining-scripts-main
```

Now you may reinstall the mining script.

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
sudo apt install wget unzip
cd ~
```

```bash
wget https://github.com/Phala-Network/solo-mining-scripts/archive/refs/heads/main.zip
unzip main.zip
rm -r main.zip #cleaning up the installation
cd solo-mining-scripts-main/ #note this depends on your current directory
chmod +x install.sh
sudo ./install.sh en
```

You may now restart your node.

```bash
sudo phala start
``` 

##### Failed to install the DCAP driver
:information_source: The most common issue is that your mainboard may not support a DCAP driver. In this case, the script cannot automatically install the `isgx` driver and results in the following error message.

<p align="center">
  <a href="https://phala.network/">
    <img alt="Phala Network" src="https://user-images.githubusercontent.com/37558304/143471619-1116c12f-7ef5-4313-93a5-51f3ed30c355.png" height="250">
  </a>
</p>

(image of the terminal showing the DCAP driver error message) 


In this case, prior to running `sudo phala start`, you need to manually install the `isgx` driver:

```bash
sudo phala install isgx
```

##### Khala Node Stops Synching

If the Khala Chain stops synching and is stuck at a specific block and does not continue to sync, we advise you first to [restart your node](#troubleshooting).

If the synchronization still fails, you may try to delete the khala chain database on your miner's node.  
It is located in `/var/khala-dev-node/chains/khala`.

<p align="center">
  <a href="https://phala.network/">
    <img alt="Phala Network" src="https://user-images.githubusercontent.com/37558304/143770078-26a3c457-ce1d-447c-8e26-81ea0e1beb9b.png" height="100">
  </a>
</p>

(image showing the khala blockchain files of the miner node) 

It is located in `/var/khala-dev-node/chains/khala`.

First, stop your node with:

```bash
sudo phala stop
```

To delete the khala blockchain database on your node, execute the following commands:

```bash
rm -r /var/khala-dev-node/chains/khala/db
rm -r /var/khala-dev-node/chains/khala/keystore
rm -r /var/khala-dev-node/chains/khala/network
```

Now [restart your node](#troubleshooting).

##### _Head back [to top](#navigate) :point_up: to navigate to other sections._
