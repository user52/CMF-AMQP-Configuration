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

  ```DEVICE="eth0"
  BOOTPROTO="dhcp"
  NM_CONTROLLED="yes"
  ONBOOT=yes
  TYPE="Ethernet"
  UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  IPV6INIT=yes
  HWADDR=xx:xx:xx:xx:xx:xx
```

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