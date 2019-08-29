#!/bin/bash

# Configures a simple web server (node) which states the private IP addres

# Install node from source
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get update
sudo apt-get install -y nodejs

# Install pm2
sudo npm install -g pm2

# Basic web server files
cat > server.js << EOF
// Simple web server that says hello and local IP address of the server
var express = require('express');
var app = express();
var os = require('os');

// Finds IPv4 interface IP for specificed interface name
const interfaces = os.networkInterfaces();
const interface_name = 'eth0'; 
const interface = interfaces[interface_name];
const interface_ip = interface ? interface.find(int => int.family == 'IPv4').address : 'Unknown IP';

// Server port
const port = 80;

// Routes
app.get('/', async (req, res) => {    
    // Custom header for test cases
    res.header('x-served-from', interface_ip);

    // Response with server IP 
    res.send(\`Hello! I am \${interface_ip}\`);

});

// Start the app
app.listen(port);
EOF

cat > package.json << EOF
{
  "name": "webapp",
  "version": "1.0.0",
  "description": "This is a simple web server!",
  "main": "server.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.17.1"
  }
}
EOF

# Install dependencies
sudo npm -y install

# Allow user access to port 80
sudo apt-get -y install authbind
sudo touch /etc/authbind/byport/80
sudo chown al /etc/authbind/byport/80
sudo chmod 755 /etc/authbind/byport/80

# Run web app
authbind --deep pm2 start server.js --name "AL-Web-Server"

# Persist
eval "$(pm2 startup)"
pm2 save
vi
