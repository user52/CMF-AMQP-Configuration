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
  
  ```# Firewall configuration written by system-config-firewall
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
  COMMIT
```
  
  We want to add the following entries to the top of the file, right under the `:OUTPUT ACCEPT [2:120]` line: 
  
  ```-A INPUT -p tcp -m tcp --dport 15672 -j ACCEPT
  -A INPUT -p tcp -m tcp --dport 5672 -j ACCEPT
  -A INPUT -p tcp -m tcp --dport 5673 -j ACCEPT
```
  
  Your file should look something like this when you are done.
  
  ```*filter
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
  COMMIT
```

2.  Restart *iptables*.

  `sudo service iptables restart`

## Using the *iptables* command to add rules.

1.  For each port you need unblocked, you will follow the pattern:
  
  `sudo iptables -I INPUT 1 -p tcp --dport [port #] -j ACCEPT`
  
  So to unblock the non-SSL, SSL and Management Console:
  
  ```sudo iptables -I INPUT 1 -p tcp --dport 5672 -j ACCEPT
  sudo iptables -I INPUT 1 -p tcp --dport 5673 -j ACCEPT
  sudo iptables -I INPUT 1 -p tcp --dport 15672 -j ACCEPT
```

  > Note that the `-I INPUT 1` literally means to register this rule before other rules.  If you don't do this, *iptables* will not open your port because a previous rule will supersede that rule, blocking access to the port.

2.  Now we need to save the configuration:

  `sudo service iptables save`

3.  And restart *iptables*:

  `sudo service iptables restart`

## Verification

Test that you can access the ports.  There is a test client for AMQP provided in the [CMF-AMQP-Configuration Repository](https://github.com/Berico-Technologies/CMF-AMQP-Configuration).  Testing the RabbitMQ Management Console is as simple as visiting the site in your browser.