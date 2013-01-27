
# Installing RabbitMQ on CentOS 6.3 Minimal

This tutorial will demonstrate how to install RabbitMQ 3.x on CentOS 6.3 ("minimal" profile).

This install was performed using VMWare Fusion on OSX, but should demonstrate the process on most environments using Linux-supported drivers.  The virtual was 1-core, 1.6GB RAM, 6GB HDD space; I did not use the quick setup VMWare offers.

There are two ways of installing RabbitMQ on CentOS.  The ways differ based on which distribution of Erlang you chose to use (the one out of EPEL or a later version from Erlang Solutions).  We will demonstrate both ways in this example.

One of the goals of this tutorial is to not install anymore software than needed.  We will use "vi" instead of "pico" or "nano" because that's what's bundled with CentOS minimal profile.  If you would rather use another text editor, please install it on your own.

## Install Linux

### Example Settings:
 - Hostname: rabbit3.warren
 - Root Password: rabbit
 - Disk: Use all space and let CentOS allocate as it sees fit.
 - Profile.  Use default [minimal].  This will not include a GUI.

<a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i01.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i01.png">
</a>

### Installs...

<a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i02.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i02.png">
</a>

### Reboot the machine.

<a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i03.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i03.png">
</a>

## Create the Rabbit account

We don't want to do everything as root, so we'll create an account called "rabbit".

1.  Login as root (password=rabbit)
2.  Create the 'rabbit' user account.

  `# -m creates the home directory
  adduser rabbit -m`

3.  Change user "rabbit"'s password to "rabbit".

  `# using "rabbit" as password
  passwd rabbit`

4.  Add "rabbit" to the sudoers file.

  `vi /etc/sudoers`

  Add the following line in the file:

  `rabbit  ALL=(ALL) ALL`

5.  Log in as user "rabbit"

  `su - rabbit`


## Configure Networking

Network settings will depend on your network environment.  The following reflects a DHCP setup.

1.  Edit the settings for your network device.  This will be a file in `/etc/sysconfig/network-scripts/`, probably `ifcfg-eth0`:

  `sudo /etc/sysconfig/network-scripts/ifcfg-eth0`

  Make your config file look something like this.

  `DEVICE="eth0"
  BOOTPROTO="dhcp"
  NM_CONTROLLED="yes"
  ONBOOT=yes
  TYPE="Ethernet"
  UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  IPV6INIT=yes
  HWADDR=xx:xx:xx:xx:xx:xx`

  > Where the x's are specific to your machine.  Much of this information will already by in the file.  You will probably only need to set "ONBOOT" to "yes".

2.  Restart the network service.

  `sudo service network restart`

3.  Verify the internet (or intranet) is accessible.

  `curl www.google.com`

## Update the OS

At the time of this posting, there was 43 updates to the OS and core packages installed on the minimum profile.  We'll update them now to ensure the OS has it's security patches and bug fixes applied.

`sudo yum update`

> This is about 180mb; install took about 5 minutes.

We will also install `wget`, a common Linux utility for downloading files which is not included in the minimum profile.  

`sudo yum install wget`

> For security reasons, it's probably best to remove this when your done installing and configuring your server.

`sudo yum remove wget`

## Install Erlang Dependencies

These are the minimum number of libraries needed to install Erlang, which is the only dependency of RabbitMQ

`sudo yum install gcc glibc-devel make ncurses-devel openssl-devel autoconf`

> About 34mb and should take a couple of minutes.

## Acquire RabbitMQ RPM

This is the last common step in the install.  We will import the RabbitMQ company's public key and then download the RPM from their website.

1.  Import RabbitMQ's Public Key

  `sudo rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc`

2.  Download RabbitMQ RPM.  Were assuming you are downloading this to the "rabbit" user's home folder `/home/rabbit`:

  `wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.0.1/rabbitmq-server-3.0.1-1.noarch.rpm`

> The file is only about 3.5mb and should download in about 3s.

## Installing Erlang

There are two options for installing Erlang via RPM:

1.  Use the EPEL repository.  There is a reasonably new (couple months old) Erlang distribution (R14B) available, and the RabbitMQ RPM's dependencies map to this Erlang RPM.  This is the cleanest install, but you don't benefit from having a newer Erlang VM.

2.  Use the Erlang Solutions' RPM.  The company is creating RPM's of the latest Erlang releases (R15B03) and making them available from their website.  Checking the Erlang project site, the RPM provided was the latest version of Erlang available at the time.  The RabbitMQ RPM will cry about unsatisfied dependencies when installed this method unless the --nodeps flag is used to install the RPM.

### Installing via EPEL

1.  Download the EPEL RPM.

  `wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm`

2.  Install the EPEL RPM.

  `sudo rpm -Uvh epel-release-6*.rpm`

3.  Install Erlang via "yum"

  `sudo yum install erlang`

### Installing via Erlang Solutions RPM

1.  Import Erlang Solutions Certificate

  `sudo rpm --import http://binaries.erlang-solutions.com/debian/erlang_solutions.asc`

2.  Download the Erlang RPM from Erlang Solutions

  `wget https://elearning.erlang-solutions.com/couchdb//rbingen_adapter//package_R15B03_centos664_1355850825/esl-erlang-R15B03-2.x86_64.rpm
`

  > This download is uber slow, so please be patient.  If you want, you are welcome to download the R15B03 RPM from me: https://dl.dropbox.com/u/12311372/esl-erlang-R15B03-2.x86_64.rpm

3.  Install the Erlang Solutions RPM

  `sudo yum install esl-erlang-R15B03-2.x86_64.rpm`

> Thank you [Jim Jose](http://blog.jimjose.in/) whose [article](http://blog.jimjose.in/2012/04/installing-rabbitmq-2-8-with-erlang-r15b-on-centos6/) helped in finding an up-to-date Erlang RPM.

## Installing RabbitMQ

### If your Erlang RPM is from EPEL

`sudo yum install rabbitmq-server-3.0.1-1.noarch.rpm`

### If your Erlang RPM is from Erlang Solutions

`sudo rpm --nodeps -Uvh rabbitmq-server-3.0.1-1.noarch.rpm`


## Verify RabbitMQ Installation

Start the RabbitMQ server to ensure it was correctly installed:

`sudo service rabbitmq-server start`

<a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i04.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i04.png">
</a>

>  *iptables* is turned on automatically with a CentOS install. In order to connect to the broker, you will need to either turn *iptables* off (`sudo service iptables stop`) or configure *iptables* to allow connections on port 5672.  For more on *iptables* and RabbitMQ, go to the "Configuring *iptables* for RabbitMQ" section.





# Enabling RabbitMQ Management Console

1.  Ensure RabbitMQ is running.

  `sudo service rabbitmq-server start`

2.  Enable the RabbitMQ Management Console

  `sudo rabbitmq-plugins enable rabbitmq_management`

3.  Restart RabbitMQ.

  `sudo service rabbitmq-server restart`

>  *iptables* is turned on automatically with a CentOS install. In order to visit the RabbitMQ Management Console, you will need to either turn *iptables* off (`sudo service iptables stop`) or configure *iptables* to allow connections on port 15672.  For more on *iptables* and RabbitMQ, go to the "Configuring *iptables* for RabbitMQ" section.






# Configuring *iptables* for a single instance of RabbitMQ

It's common for developers to turn off *iptables* because it's an annoyance, but for an integration or production system, this is a nonstarter (*iptables* needs to be turned on).  Fortunately, configuring *iptables* is rather easy.

There are two ways of configuring *iptables*:

1.  Edit the *iptables* configuration directly.
2.  Use the `iptables` command to add or remove rules.

Using either method, we need to open of 1-3 ports, depending on your use-case:

- **5672**:  The default port for AMQP connections.
- **5673**:  The default port for TLS/SSL AMQP connections.
- **15672**:  The default port for the RabbitMQ Management Console.

> The RabbitMQ Management Console used to use the port **55672**, so if you are using an older version of Rabbit, adjust accordingly. 

## Editing the *iptables* configuration file.

1.  Open the `/etc/sysconfig/iptables` file for editing.

  Your current file should look like this.

  `# Firewall configuration written by system-config-firewall
  \# Manual customization of this file is not recommended.
  *filter
  :INPUT ACCEPT [0:0]
  :FORWARD ACCEPT [0:0]
  :OUTPUT ACCEPT [0:0]
  -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  -A INPUT -p icmp -j ACCEPT
  -A INPUT -i lo -j ACCEPT
  -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
  -A INPUT -j REJECT --reject-with icmp-host-prohibited
  -A FORWARD -j REJECT --reject-with icmp-host-prohibited
  COMMIT`
  
  We want to add the following entries to the top of the file, right under the `:OUTPUT ACCEPT [2:120]` line: 
  
  `-A INPUT -p tcp -m tcp --dport 15672 -j ACCEPT
  -A INPUT -p tcp -m tcp --dport 5672 -j ACCEPT
  -A INPUT -p tcp -m tcp --dport 5673 -j ACCEPT`
  
  Your file should look something like this when you are done.
  
  `*filter
  :INPUT ACCEPT [0:0]
  :FORWARD ACCEPT [0:0]
  :OUTPUT ACCEPT [2:120]
  -A INPUT -p tcp -m tcp --dport 15672 -j ACCEPT
  -A INPUT -p tcp -m tcp --dport 5672 -j ACCEPT
  -A INPUT -p tcp -m tcp --dport 5673 -j ACCEPT
  -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
  -A INPUT -p icmp -j ACCEPT 
  -A INPUT -i lo -j ACCEPT 
  -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT 
  -A INPUT -j REJECT --reject-with icmp-host-prohibited 
  -A FORWARD -j REJECT --reject-with icmp-host-prohibited 
  COMMIT`

2.  Restart *iptables*.

  `sudo service iptables restart`

## Using the *iptables* command to add rules.

1.  For each port you need unblocked, you will follow the pattern:
  
  `sudo iptables -I INPUT 1 -p tcp --dport [port #] -j ACCEPT`
  
  So to unblock the non-SSL, SSL and Management Console:
  
  `sudo iptables -I INPUT 1 -p tcp --dport 5672 -j ACCEPT
  sudo iptables -I INPUT 1 -p tcp --dport 5673 -j ACCEPT
  sudo iptables -I INPUT 1 -p tcp --dport 15672 -j ACCEPT`

  > Note that the `-I INPUT 1` literally means to register this rule before other rules.  If you don't do this, *iptables* will not open your port because a previous rule will supersede that rule, blocking access to the port.

2.  Now we need to save the configuration:

  `sudo service iptables save`

3.  And restart *iptables*:

  `sudo service iptables restart`

## Verification

Test that you can access the ports.  There is a test client for AMQP provided in the [CMF-AMQP-Configuration Repository](https://github.com/Berico-Technologies/CMF-AMQP-Configuration).  Testing the RabbitMQ Management Console is as simple as visiting the site in your browser.






# Configuring *iptables* for a RabbitMQ Cluster

In this tutorial, we will configure *iptables* and RabbitMQ to allow RabbitMQ brokers to coordinate with each other.  This example builds on the previous tutorial *Configuring **iptables** for a single instance of RabbitMQ*, so we will only demonstrate how to configure *iptables* using the `iptables` command.

More importantly, the steps in this tutorial need to be performed on every node in the RabbitMQ cluster.

1.  Edit the RabbitMQ configuration file to force Erlang to use the specified port range when using the "Erlang Distribution Protocol".

  >  Erlang has a special "inter-process communication" framework allowing processes on the same machine, or across a network, to communicate with each other.  It is this mechanism that RabbitMQ uses to coordinate between brokers.  However, unless told not to do so, Erlang will randomly choose the ports it will use to communicate.

  a.  Edit/Create the RabbitMQ configuration file.

  >  RabbitMQ configuration is stored in the `/etc/rabbitmq/` directory in the `rabbitmq.config` file.  On virgin installs, this file will not exist and will have to be created.  RabbitMQ will detect the presence of `rabbitmq.config` when it is started and configure itself accordingly.  Think of this file as an `overrides` file.  You do not have to fully configure RabbitMQ in this file, merely override the settings you need changed.

  `sudo vi /etc/rabbitmq/rabbitmq.config`

  b.  Instruct the Erlang kernel to use the following port range (9100-9105) for the Erlang Distribution protocol:

  `[{kernel, [ {inet_dist_listen_min, 9100}, 
                {inet_dist_listen_max, 9105} ]}].`

  > RabbitMQ's configuration is quite literally an Erlang *tuple*.  That's the reason why it has a *funky* syntax.

  c.  Restart RabbitMQ.

  `sudo service rabbitmq-server restart`

2.  Add rules to *iptables* to allow RabbitMQ to communicate with other RabbitMQ brokers.

  a.  First we need to unblock the EPMD port (Erlang Port Mapper Daemon); EPMD is a registry Erlang uses to determine which applications are running and on what port.

  `sudo iptables -I INPUT 1 -p tcp --dport 4369 -j ACCEPT`

  b.  Next, we need to unblock port range RabbitMQ will use for interprocess communication:

  `sudo iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 9100:9105 -j ACCEPT`

  c.  Save the configuration.

  `sudo service iptables save`

  d.  Finally, restart *iptables*.

  `sudo service iptables restart`

3.  As a final precautionary step, reboot the server.

  `sudo reboot`

  >  The Erlang Distribution protocol requires services to register with a unique name (RabbitMQ uses "rabbit").  Sometimes the Erlang process registered with the "rabbit" handle will fail to stop.  Rebooting the machine will force the process to end and EPMD to restart, solving this problem.

## Verification

We'll verify that this works when we *Cluster Rabbit*, in the next tutorial.

> Thank you to the author of the [Loose XAML](http://loosexaml.wordpress.com/) blog for an excellent [article](http://loosexaml.wordpress.com/2012/08/06/rabbitmq-clustering-on-centos-6-12/) on configuring RabbitMQ and *iptables* for clustering.







# Clustering RabbitMQ

There are two ways to cluster RabbitMQ.  The first is to use the commands provided by `rabbitmqctl` and the second is to use configuration.  This tutorial will only demonstrate the first way, in part, because it can be done in a consistent fashion.  We encountered a couple of issues using "Auto-configuration" which caused contention between nodes.  This may have been an error on our part, but given the fact that the `rabbitmqctl` method is actually easier, we didn't invest any time into figuring out the error in our ways.

1.  Ensure you can reach all the nodes in your cluster.

  >  If you have been following this tutorial, you will note that we have not setup DNS or edited the hosts file.  For this tutorial we will add some entries into the host file as a simple solution.  If you already have networking setup in your cluster and can reach nodes by hostname, please ignore.

  a.  Find out the IP's of each node in your cluster.

  On each server, execute:

  `ifconfig`

  Write down the IP address of that server.  It will probably be the `inet addr` entry under either `eth0` or `eth1` (left column).

  b.  Edit the `/etc/hosts` file of each server.

  `sudo vi /etc/hosts`

  Add an entry in the `hosts` file for every server in the cluster but the one you are physically on:

  `xxx.xxx.xxx.xxx {hostname} {hostname}.{domain}`

  For this tutorial, it would look like:

  `127.0.0.1 localhost rabbit3 rabbit3.warren localhost4
  192.168.192.154 rabbit1 rabbit1.warren
  192.168.192.153 rabbit2 rabbit2.warren`

  > We've also added the `rabbit3` entry to `localhost` so the machine knows it should loopback to itself.

  Save the file and you are done.  Make sure all the nodes can reach each other:

  `ping rabbit1
  ping rabbit2`

  > Press `control-z` to stop the `ping` command from *pinging* the server.

2.  Ensure all nodes share the same Erlang cookie.

  > The Erlang Distribution protocol will have Erlang processes authenticate with each other to ensure those processes are allowed to interact.  The algorithm used to perform the authentication is hash-based, that hash being stored in the "cookie" file.

  a.  Chose a server in your cluster whose cookie will serve as the "canonical" cookie of the cluster.  Which server doesn't particularly matter.

  b.  Copy the cookie from that server to all other servers participating in the cluster.  The cookie is stored in the `/var/lib/rabbitmq` directory and is called `.erlang.cookie`. Please note the period (.) in the name of the cookie (a hidden file in UNIX), so it won't come up in a `ls` command unless you use the -a switch (`ls -a`).

  >  We recommend using `scp` to perform the copy, but you may choose any mechanism you want.  We will demonstrate the `scp` method.

  `sudo scp /var/lib/rabbitmq/.erlang.cookie \
         {user}@{host}:/home/{user}/erlang.cookie`

   Replace {user} and {host} with the correct values.  In the case of this ongoing tutorial:

  `sudo scp /var/lib/rabbitmq/.erlang.cookie \
         rabbit@rabbit3:/home/rabbit/erlang.cookie`

  > Please note that there is no period "." in the name of `erlang.cookie` file we are transferring to the *rabbit3* server.  This is because Linux will tell you `Permission denied` because it does not allow the creation of hidden files from a remote machine.  This is also the reason why we are copying the file to the home directory and not directly to `/var/lib/rabbitmq`.

  > If you do not have `scp` installed on your machine (which is likely if you are using CentOS minimal profile), you can install it using `sudo yum install openssl-client`.

  Move the cookie to the `/var/lib/rabbitmq` directory:

  `sudo mv erlang.cookie /var/lib/rabbitmq/.erlang.cookie`

  > And we've added the period "." back to the file's name.

  This next step is precautionary.  Moving the cookie from one server to another may cause the file to be unaccessible to the *rabbitmq* user account (which runs the server).  With this in mind, we will transfer ownership of the cookie file to the *rabbitmq* user:

  `sudo chmod rabbitmq /var/lib/rabbitmq/.erlang.cookie`

  Restart RabbitMQ:

  `sudo service rabbitmq-server restart`

3.  Use `rabbitmqctl` to cluster the nodes.

  To cluster a RabbitMQ node, you need to stop the RabbitMQ application on the Erlang VM, reset the node's configuration, tell it to going the cluster, and then start back up.

  Stop the broker:

  `sudo rabbitmqctl stop_app`

  Reset the configuration on the node.  This is only necessary if your node was previously joined to another cluster.

  `sudo rabbitmqctl reset`

  Join the cluster:

  `sudo rabbitmqctl join_cluster rabbit@rabbit1`

  Start the broker:

  `sudo rabbitmqctl start_app`

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i05.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i05.png">
</a>

  >  *rabbit@rabbit1* probably doesn't mean what you think.  It actually means the Erlang Distribution identifier for a process called  "rabbit" on the host "rabbit1".  When joining a cluster, there isn't any kind of "master" or "leader" node.  You could actually join the cluster by specifying *rabbit@rabbit2* and it would work identically.

  >  By default, your node will be a "disk node".  Disk nodes store their state both on disk and in memory.  You can choose to have "ram nodes" which store their state in memory, unless a queue declared on that broker is configured to be persistent.

  To join a node on the cluster as a RAM node:

  `sudo rabbitmqctl join_cluster --ram rabbit@rabbit1`

  To change the local cluster node to another type (back to disc):

  `sudo rabbitmqctl stop_app
  sudo rabbitmqctl change_cluster_node_type disc
  sudo rabbitmqctl start_app`

  Alternatively to change a disc node to a ram node:

  `sudo rabbitmqctl stop_app
  sudo rabbitmqctl change_cluster_node_type ram
  sudo rabbitmqctl start_app`

## Verify the Cluster's Status

1.  `rabbitmqctl` offer the capability to determine the cluster's status from the shell:

  `sudo rabbitmqctl cluster status`

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i06.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i06.png">
</a>

2.  The RabbitMQ Management Console is probably the best way to see the cluster's status, providing rich statistics about each node in the cluster.  Simply navigate to one of your Console instances in the browser.

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i07.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i07.png">
</a>



# Configuring SSL for RabbitMQ

Configuring RabbitMQ for SSL is a fairly straight forward process.  It involves generating the certificates and key file for the server to perform SSL, and registering those files with RabbitMQ via the `rabbitmq.config` file.

## Generating Certificates

The difficult part of this process is knowing how to generate and manage Public-Key Infrastructure.  If you are unfamiliar with this process, or work in an organization that already has it's own infrastructure, we would recommend you consult with whomever manages that infrastructure to get the correct keys and certificates.

In the event that you need to do this work on your own, we have a created a set of scripts that will simplify the process.  These scripts literally automate the process documented by RabbitMQ on this [page](http://www.rabbitmq.com/ssl.html).

1.  Install `git` on a machine of your choice.  This does not have to be on one of the cluster nodes, but you will have to copy files to each broker if you do not.

  `sudo yum install git`

2.  Clone the [CMF-AMQP-Configuration](https://github.com/Berico-Technologies/CMF-AMQP-Configuration) repository.

  `git clone https://github.com/Berico-Technologies/CMF-AMQP-Configuration.git`

  Change into the `CMF-AMQP-Configuration/ssl/` directory:

  `cd CMF-AMQP-Configuration/ssl/`

  In this directory you will find the following files:

  -  openssl.cnf:  This is the OpenSSL configuration file.
  -  setup_ca.sh:  This will setup the Certificate Authority you will need to generate and issue client and server certificates from.
  -  make_server_cert.sh:  This will generate a certificate for a server (like a RabbitMQ Broker).
  -  create_client_cert.sh:  This will generate a certificate for a client application (connecting to a RabbitMQ Broker).
  -  implode.sh:  This will remove all directories and content generated by the other scripts, but it will not delete the scripts of configuration.

  >  If you choose to fork this configuration in GitHub, the .gitignore file in this directory will prevent the inclusion of the certificate files.

3. Edit the `openssl.cnf` file (as needed).

  Here you can specify default values for the certificate.  Please see the OpenSSL documentation to get a full list of values.

  By default, this file will force a SHA1 2048-bit key good for 1 year.

4.  Generate a Certificate Authority.

  > You may need to use `sudo` depending on where you put the project.

  `sh setup_ca.sh [certificate authority common name (CN)]`

  For example:

  `sh setup_ca.sh OfficeMagiCA`

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i08.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i08.png">
</a>

5.  Generate a Server Certificate.

  > You may need to use `sudo` depending on where you put the project.

  `sh make_server_cert.sh [hostname] [password]`

  For example:

  `sh make_server_cert.sh rabbit3 rabbit`

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i09.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i09.png">
</a>

6.  (Optional) Generate a Client Certificate

  This will not be used during this portion of the tutorial.

  > You may need to use `sudo` depending on where you put the project.

  `sh create_client_cert.sh [client name] [password]`

  For example:

  `sh create_client_cert.sh rabbit-client1 rabbit`

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i10.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i10.png">
</a>

7.  Copy the certificates to your RabbitMQ Broker.

  The previous processes will have generated a lot of files that you will not need at the Broker.  Many of these files were created in the process of generating certificate signing requests (CSR), where a server or client certificate is "stamped" by the CA to establish a "chain of trust".

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i11.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i11.png">
</a>

  For this tutorial, we will need the following certificates:

  - ca/cacert.pem:  The Certificate Authority's certificate.
  - server/{hostname}.cert.pem:  The Server/Broker's certificate.
  - server/{hostname}.key.pem:  The Server/Broker's private key.

  > Protect the *.key.pem at all costs!  This is literally the password to the certificate (i.e.: don't give this out).

  We have taken the convention of storing the certificates in a folder called `ssl` located in the RabbitMQ configuration directory (`/etc/rabbitmq/`).

  Preserving the structure created by the CMF-AMQP-Configuration project, copy those files into the directory:

  `sudo mkdir -p /etc/rabbitmq/ssl/ca
  sudo mkdir /etc/rabbitmq/ssl/server
  sudo cp {/path/to/CMF-AMQP-Configuration/ssl/}ca/cacert.pem \
      /etc/rabbitmq/ssl/ca/cacert.pem
  sudo cp {/path/to/CMF-AMQP-Configuration/ssl/}server/{hostname}.key.pem \
      /etc/rabbitmq/ssl/server/{hostname}.key.pem
  sudo cp {/path/to/CMF-AMQP-Configuration/ssl/}server/{hostname}.cert.pem \
      /etc/rabbitmq/ssl/server/{hostname}.cert.pem`

  Using our example, it looks like:

  `sudo mkdir -p /etc/rabbitmq/ssl/ca
  sudo mkdir /etc/rabbitmq/ssl/server
  sudo cp {/path/to/CMF-AMQP-Configuration/ssl/}ca/cacert.pem \
      /etc/rabbitmq/ssl/ca/cacert.pem
  sudo cp {/path/to/CMF-AMQP-Configuration/ssl/}server/rabbit3.key.pem \
      /etc/rabbitmq/ssl/server/rabbit3.key.pem
  sudo cp {/path/to/CMF-AMQP-Configuration/ssl/}server/rabbit3.cert.pem \
      /etc/rabbitmq/ssl/server/rabbit3.cert.pem`

## Configuring RabbitMQ to support SSL Connections

To configure RabbitMQ to support SSL, you simply need to add some minor configuration options to the `rabbitmq.config` in the `/etc/rabbitmq` directory.  

>  If the file doesn't exist, we simply need to create it and RabbitMQ will pick up those changes upon start/restart.

1.  Edit the `rabbitmq.config` file:

  `sudo vi /etc/rabbitmq/rabbitmq.config`

2.  Add the following configuration:

  `[
    {rabbit, [ {tcp_listeners, [5672] },
               {ssl_listeners, [5673] },
               {ssl_options, [
                 {cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem" },
                 {certfile, "/etc/rabbitmq/ssl/server/{hostname}.cert.pem" },
                 {keyfile, "/etc/rabbitmq/ssl/server/{hostname}.key.pem" },
                 {verify, verify_peer},
                 {fail_if_no_peer_cert, false }]}
    ]}
  ].`

  Where our configuration looks like:

  `[
    {rabbit, [ {tcp_listeners, [5672] },
               {ssl_listeners, [5673] },
               {ssl_options, [
                 {cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem" },
                 {certfile, "/etc/rabbitmq/ssl/server/rabbit3.cert.pem" },
                 {keyfile, "/etc/rabbitmq/ssl/server/rabbit3.key.pem" },
                 {verify, verify_peer},
                 {fail_if_no_peer_cert, true }]}
    ]}
  ].`

  And if you are already clustered with `iptables` configured:

  `[
    {rabbit, [ {tcp_listeners, [5672] },
               {ssl_listeners, [5673] },
               {ssl_options, [
                 {cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem" },
                 {certfile, "/etc/rabbitmq/ssl/server/rabbit3.cert.pem" },
                 {keyfile, "/etc/rabbitmq/ssl/server/rabbit3.key.pem" },
                 {verify, verify_peer},
                 {fail_if_no_peer_cert, true }]}
    ]},
    {kernel, [ {inet_dist_listen_min, 9100}, 
                {inet_dist_listen_max, 9105} ]}
  ].`

  There are some important options to note:

  -  `tcp_listeners`:  This is the clear-text port to answer requests.  Remove this if you want your broker to only accept SSL.
  -  `ssl_listeners`:  This is the port to accept SSL connections.  Make sure you have enabled that port in *iptables*.
  
  The SSL-specific options (`ssl_options`):
    -  `cacertfile`:  The certificate file of the CA.
    -  `certfile`:  The certificate of this broker.
    -  `keyfile`:  The private key of this broker.
    -  `verify`:  If "verify_peer" is set, the client must present a certificate that will be verified by the broker.
    -  `fail_if_no_peer_cert`:  This is supposed to mean that the connection will fail if the peer does not preset a certificate and this property is set to true.  But do to a bug in Erlang, if the `{verify, verify_peer}` option is set, `fail_if_no_peer_cert` is ignored if set to false (i.e.: client will have to supply a validated certificate).

3.  Restart RabbitMQ.

  `sudo service rabbitmq-server restart`

## Verifying SSL

1.  We have supplied a test client to verify if the SSL connection works in the [CMF-AMQP-Configuration Repository](https://github.com/Berico-Technologies/CMF-AMQP-Configuration).

2.  Alternatively, the RabbitMQ Management Console lists the available ports for clients to connect on the main page:

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i12.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i12.png">
</a>




# Securing the RabbitMQ Management Console with SSL.

The process for securing the RabbitMQ Management Console with SSL is very similar to securing the AMQP port.  Instead of rehashing how to do certificates, we will assume that you had followed the tutorial on *Configuring SSL for RabbitMQ* and are now securing the console.

In *Configuring SSL for RabbitMQ*, we took the convention of using the `/etc/rabbitmq/ssl` directory for storing certificates.  If you followed the directions in that post, you should already have the certificates you need for securing the console.  Alternatively, if you choose to use a separate certificate for the Management Console than the AMQP port, simply create a new certificate and key using the `make_server_cert.sh` script.

## Configure RabbitMQ to use SSL for the RabbitMQ Management Console.

1.  Edit the `rabbitmq.config` file in the `/etc/rabbitmq` directory:

  `sudo vi /etc/rabbitmq/rabbitmq.config`

2.  Add a configuration entry:

  `[{rabbitmq_management,
      [{listener, 
        [{port, 15672},
         {ssl, true},
         {ssl_opts, 
           [{cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem"},
            {certfile,   "/etc/rabbitmq/ssl/server/{hostname}.cert.pem"},
            {keyfile,    "/etc/rabbitmq/ssl/server/{hostname}.key.pem"}]}
         ]}
    ]}
  ].`

  And of course, using our example:

  `[{rabbitmq_management,
      [{listener, 
        [{port, 15672},
         {ssl, true},
         {ssl_opts, 
           [{cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem"},
            {certfile, "/etc/rabbitmq/ssl/server/rabbit3.cert.pem"},
            {keyfile, "/etc/rabbitmq/ssl/server/rabbit3.key.pem"}]}
         ]}
    ]}
  ].`

  More importantly, the config with AMQP/SSL, `iptables` port range for clustering, and the Management console using SSL:

  `[
    {rabbit, [ {tcp_listeners, [5672] },
               {ssl_listeners, [5673] },
               {ssl_options, [
                 {cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem" },
                 {certfile, "/etc/rabbitmq/ssl/server/rabbit3.cert.pem" },
                 {keyfile, "/etc/rabbitmq/ssl/server/rabbit3.key.pem" },
                 {verify, verify_peer},
                 {fail_if_no_peer_cert, true }]}
    ]},
    {rabbitmq_management,
      [{listener, 
        [{port, 15672},
         {ssl, true},
         {ssl_opts, 
           [{cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem"},
            {certfile, "/etc/rabbitmq/ssl/server/rabbit3.cert.pem"},
            {keyfile, "/etc/rabbitmq/ssl/server/rabbit3.key.pem"}]}
         ]}
     ]},
    {kernel, [ {inet_dist_listen_min, 9100}, 
                {inet_dist_listen_max, 9105} ]}
  ].`

3.  Restart RabbitMQ.

  `sudo service rabbitmq-server start`


## Verify SSL on Management Console

Open your browser to the RabbitMQ Management Console, but don't forget to use "https".

<a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i13.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i13.png">
</a>

## Forcing the Browser to Authenticate using Certificates.

1.  Edit the `rabbitmq.config` file in the `/etc/rabbitmq` directory.

  Add `	{verify, verify_peer}, {fail_if_no_peer_cert, true }` to the `ssl_options`  of `rabbitmq_management`.

  ```[{rabbitmq_management,
      [{listener, 
        [{port, 15672},
         {ssl, true},
         {ssl_opts, 
           [{cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem"},
            {certfile, "/etc/rabbitmq/ssl/server/{hostname}.cert.pem"},
            {keyfile, "/etc/rabbitmq/ssl/server/{hostname}.key.pem"},
            {verify, verify_peer},
            {fail_if_no_peer_cert, true }]}
         ]}
    ]}
  ].
```

  Which now looks like:

  ```[
    {rabbit, [ {tcp_listeners, [5672] },
               {ssl_listeners, [5673] },
               {ssl_options, [
                 {cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem" },
                 {certfile, "/etc/rabbitmq/ssl/server/rabbit3.cert.pem" },
                 {keyfile, "/etc/rabbitmq/ssl/server/rabbit3.key.pem" },
                 {verify, verify_peer},
                 {fail_if_no_peer_cert, true }]}
    ]},
    {rabbitmq_management,
      [{listener, 
        [{port, 15672},
         {ssl, true},
         {ssl_opts, 
           [{cacertfile, "/etc/rabbitmq/ssl/ca/cacert.pem"},
            {certfile, "/etc/rabbitmq/ssl/server/rabbit3.cert.pem"},
            {keyfile, "/etc/rabbitmq/ssl/server/rabbit3.key.pem"},
            {verify, verify_peer},
            {fail_if_no_peer_cert, true }]}
         ]}
     ]},
    {kernel, [ {inet_dist_listen_min, 9100}, 
                {inet_dist_listen_max, 9105} ]}
  ].
```

2.  Restart RabbitMQ.

  sudo service rabbitmq-server restart`

##  Verify Certificate Authentication

Visit the RabbitMQ Management Console **without** a certificate from the broker's CA installed in your browser.

<a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i14.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i14.png">
</a>

## Generate and Install Client Certificate for Browser-based Authentication.

Each browser and sometimes browser-OS pairing has a different way of installing certificates.  

1.  Generate a Client Certificate.

  Using the `create_client_cert.sh` script, generate a certificate for your user.

  `sh create_client_cert.sh {username} {password}`

  For example:

  `sh create_client_cert.sh jdoe password123`

  In the `ssl/client` directory, you will see a couple of new files:

  - `jdoe.key.pem`:  John Doe's private key
  - `jdoe.cert.pem`:  John Doe's public key
  - `jdoe.req.pem`:  John Doe's certificate signing request (CSR)
  - `jdoe.keycert.p12`:  John Doe's Public-Private Key pair that can be used by the operating system or browser.

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i15.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i15.png">
</a>

2.  Install the Certificate for Chrome and Safari.

  Browsers like Chrome and Safari that use the underlying OS's keystore.  So the instructions will depend on the OS.  This is how to do it in OSX.

  a.  Double-click the `jdoe.keycert.p12`, and OSX at the very least, will install the certificate into its *Keychain*:

  b.  You will be prompted for the password you entered in the `create_client_cert.sh` command.

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i16.png"><img style="max-height: 500px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i16.png">
</a>

  c.  Visit the RabbitMQ Management Console again.

  d.  You will be prompted to select a certificate.  In this case, there will only be one to select:

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i17.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i17.png">
</a>

  e.  Chrome will prompt you for permission to sign the request with your private key:

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i18.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i18.png">
</a>

  And you should be in!

3.    Install the Certificate for Firefox.

  a.  Navigate in the menu to **Preferences** -> **Advanced** -> **Encryption**.

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i19.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i19.png">
</a>

  b.  Press the "View Certificates" button.

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i20.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i20.png">
</a>

  c.  Press the "Import..." button, and select the certificate to install (in our case `joe.keycert.p12`).  Enter the password used for the creation of the certificate when you executed the `create_client_cert.sh` command ("password123" for the example).

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i21.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i21.png">
</a>

  d.  If the password is correct, Firefox will congratulate you.

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i22.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i22.png">
</a>

  e.  You will now see the certificate in the "Your Certificates" tab of the "Certificate Manager" window.  Our example certificate for "jdoe" is at the bottom:

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i23.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i23.png">
</a>

  f.  Visit the RabbitMQ Management Console again.

  g.  You will be prompted for a Certificate, Firefox will automatically select the best certificate based on the Certificate Authority.

  <a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i24.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i24.png">
</a>

  h. After you've pressed "OK", you should be in!


########################################################

Binding non-SSL-capable AMQP Clients to SSL RabbitMQ
- install stunnel
- configure stunnel
- generate client certificate
- start stunnel
- start client

########################################################

Securing Cluster nodes via Erlang SSL Distribution
- You can't, at least I haven't figured it out.
- process.

########################################################

Creating a RabbitMQ Cluster Enclave
- 

########################################################

Proxying-Load Balancing RabbitMQ with HA Proxy
- 