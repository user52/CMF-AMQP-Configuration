# Enabling RabbitMQ Management Console

1.  Ensure RabbitMQ is running.

  `sudo service rabbitmq-server start`

2.  Enable the RabbitMQ Management Console

  `sudo rabbitmq-plugins enable rabbitmq_management`

3.  Restart RabbitMQ.

  `sudo service rabbitmq-server restart`

>  *iptables* is turned on automatically with a CentOS install. In order to visit the RabbitMQ Management Console, you will need to either turn *iptables* off (`sudo service iptables stop`) or configure *iptables* to allow connections on port 15672.  For more on *iptables* and RabbitMQ, go to the "Configuring *iptables* for RabbitMQ" section.

## Verify RabbitMQ Management Console

Open a browser to **http://{broker_address}:15672/**, where {broker_address} is either the host name or IP Address of your broker.

You should come to a login screen:

<a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i25.png"><img
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i25.png">
</a>

The username and password are both "guest".  Once you log in, you will see the administrative interface:

<a href="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i26.png"><img style="max-width: 700px;"
  src="https://dl.dropbox.com/u/12311372/RabbitMQ-Doc/i26.png">
</a>
