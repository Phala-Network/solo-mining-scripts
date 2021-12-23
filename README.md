EN | [中文](./README.cn.md)

<p align="center">
  <a href="https://phala.network/">
    <img alt="Phala Network" src="https://avatars.githubusercontent.com/u/59632547?s=200&v=4" width="60">
  </a>
</p>


<h1 align="center">
  Phala Mining Script
</h1>

<p align="left">
    <img alt="Phala Network" src="https://user-images.githubusercontent.com/37558304/145892648-bc3562f8-47e0-4cc9-a8a1-05b1ee8baab1.png" width="45">
    <b class="heading">Ubuntu 21.10</b> <sub> early beta GUI setup [v0.01]</sub>
  </a>
</p>

```bash
wget -O - https://raw.githubusercontent.com/Phala-Network/solo-mining-scripts/improvement-test/gui.sh | bash
```

<sub> Single command installation. Use the [manual installation guide](#manual-installation) below if issues occur. Requires [whiptail](https://manpages.ubuntu.com/manpages/impish/man1/whiptail.1.html) (standard package).</sub>

## Navigate
- [Before Getting Started](#before-getting-started)
  - [BIOS & SGX](#bios-settings)
    - [Mainboard](#check-if-mainboard-is-supported)
- [Install the Phala Scripts](#install-the-phala-scripts)   
 - [How to Use the Script](#script-usage)
    - [Start the Miner](#start-the-miner)
    - [Stop the Miner](#stop-the-miner)
    - [Get Logs](#get-logs)
    - [Miner Status Check](#check-the-miners-status)
    - [Update the Phala Miner Script](#update-the-script)
    - [Docker :whale:](#stop-the-miner)
        - [Starting Phala Docker Containers Separately](#start-docker-separately)
        - [Stopping Phala Docker Containers Separately](#stop-docker-separately)
    - [:raising_hand_man: Troubleshooting](#troubleshooting)
        - [Forum](https://forum.phala.network/c/mai/42-category/42)
        - [Peer Connectivity](#peer-connectivity)
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

:point_down: More details about the hardware requirements: 

[![Phala Wiki](https://user-images.githubusercontent.com/37558304/145890328-35ee96db-2713-4f53-8d62-d90aad16ab8c.png)](https://wiki.phala.network/en-us/docs/khala-mining/1-0-hardware-requirements/)

<h1 align="center">
</h1>

#### Manual Installation

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

##### _Head back [to top](#navigate) :point_up: to navigate to other sections._

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

### Troubleshooting

The community is here to help!
Check for [existing posts](https://forum.phala.network/c/mai/42-category/42) on our forum if you are stuck. In rare circumstances, your issue may be new; feel free to post it then so that we can help. For us to be able to help you, please read the [investigating the issue](#investigating-the-issue) first, so you know how and where to get your logs from prior to posting.

### General

Most symptoms are solved by restarting your node. If you experience issues running your node, try stopping the node by:

```bash
sudo phala stop
```

And attempt a restart with 
```bash
sudo phala start
```

If you still have issues attempt to [update the script](#update-the-script).

<h1 align="center">
</h1>

##### _Head back [to top](#navigate) :point_up: to navigate to other sections._

<h1 align="center">
</h1>

##### Investigating the Issue

First, check if all required containers are running. 

```bash
sudo docker ps
```

You should have three containers running as shown in this example:

<p align="center">
  <a href="https://phala.network/">
    <img alt="Phala Network" src="https://user-images.githubusercontent.com/37558304/145825263-50d69b7e-a7e1-45c9-9eca-cc2d7d3a6b69.png" height="100">
  </a>
</p>

(image showing the miner node's running docker containers) 

To get the most recent logs of each container, you may execute:

```bash
docker logs <container_ID/container_name> -n 100 -f
```
Note that `<container_ID/container_name>` must be replaced with the container you wish the receive the logs from. In the example above the `container_ID` is `8dc34f63861e` and `container_name` would be `phala-pherry`.
\
If you attempt to post on the phala forum and do not know where the issue lies, please post [the logs](#get-logs) of all three docker containers. Copy-paste the container logs from the terminal into the forum post. 

##### Advanced Troubleshooting

In some cases, it might be beter to reinstall the mining script. 
To do this, first uninstall the script: 

```bash
sudo phala uninstall
```

Delete the mining script repository (if still on your machine) by executing: 

```bash
rm -rf $HOME/solo-mining-scripts-main
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

<h1 align="center">
</h1>

##### Peer Connectivity

Some users running nodes may find their nodes are struggling to connect to peers, which causes nodes to be dropped from the network.
You can check your node connections through executing:

```bash
sudo docker logs -f phala-node
```

For an optimal setup, you should have between 40 and 50 peers.

If you have insufficient peers do the following:
* Check your firewall settings
* Ensure there are no NAT or Policy-based filters

Feel free to read [NAT](https://en.wikipedia.org/wiki/Network_address_translation) for more information if you are curious about the root causes. Also, do not hesitate to look for existing [Phala forum posts](https://forum.phala.network/c/mai/42-category/42) before posing your issue if you are stuck. 

<h1 align="center">
</h1>

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

<h1 align="center">
</h1>

##### Khala Node Stops Synching

If the Khala Chain stops synching and is stuck at a specific block and does not continue to sync, we advise you first to [restart your node](#troubleshooting).
Prior to restarting your miner confirm that your node is stuck, through execututing:

```bash
docker logs phala-node -n 100 -f
```

Within the logs if there is an issue in synchronizing a block, it will typically look as follows:

<p align="center">
  <a href="https://phala.network/">
    <img alt="Phala Network" src="https://user-images.githubusercontent.com/37558304/146648049-4f1a098f-63ef-4263-9b18-8020d686bd8a.png" height="100">
  </a>
</p>

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
rm -rf /var/khala-dev-node/chains/khala
```

To delete the Kusama blockchain , run:

```bash
rm -rf /var/khala-dev-node/chains/polkadot
```

Now [restart your node](#troubleshooting).

##### _Head back [to top](#navigate) :point_up: to navigate to other sections._
