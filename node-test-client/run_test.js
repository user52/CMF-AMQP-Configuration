var   amqp = require("amqp")
	, config = require("./config.js");

console.log("Attempting to connect to RabbitMQ.");
console.log("Host: " + config.host);
console.log("Port: " + config.port);
console.log("VHost: " + config.vhost);

var connection = amqp.createConnection({ 
	host: config.host,
	port: config.port || 5672,
	vhost: config.vhost || "/",
	login: config.login || "guest",
	password: config.password || "guest"
});

console.log("Done with createConnection");

connection.on("error", function(e){
	console.log(e);
});

connection.on("ready", function(){
	
	console.log("Connection is ready");
	
	connection.exchange("test-exchange", {}, function(exchange){
		
		console.log("[text-exchange] created.");
		
		targetExchange = exchange;
		
		connection.queue("test-queue", function(queue){
			
			console.log("[test-queue] created.");
			
			queue.subscribe(function(msg, headers, deliveryInfo){
				
				console.log(msg.data.toString());
			});
			
			console.log("[test-queue] bound to route [test-topic].");
			
			queue.bind(exchange, "test-topic");
			
			var msgNumber = 0;

			console.log("Registering interval.");

			setInterval(function(){

				console.log("Publishing message on [test-topic].");
				
				var opts = {
					contentType: "text/plain"
				};
				
				exchange.publish(
					"test-topic",
					"This is test message number: " + (++msgNumber),
					opts);

			}, config.publishingInterval);
		});
	})
});
