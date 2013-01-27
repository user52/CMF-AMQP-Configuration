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

  ```127.0.0.1 localhost rabbit3 rabbit3.warren localhost4
  192.168.192.154 rabbit1 rabbit1.warren
  192.168.192.153 rabbit2 rabbit2.warren
```

  > We've also added the `rabbit3` entry to `localhost` so the machine knows it should loopback to itself.

  Save the file and you are done.  Make sure all the nodes can reach each other:

  ```ping rabbit1
  ping rabbit2
```

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
  
  ```sudo rabbitmqctl stop_app
  sudo rabbitmqctl change_cluster_node_type disc
  sudo rabbitmqctl start_app
```
  
  Alternatively to change a disc node to a ram node:
  
  ```sudo rabbitmqctl stop_app
  sudo rabbitmqctl change_cluster_node_type ram
  sudo rabbitmqctl start_app
```

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