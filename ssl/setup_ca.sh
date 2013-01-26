#!/bin/bash

hr="-------------------------------------------"
br=""
strength=2048
valid=365	

message="Usage:  sh setup_ca.sh [certificate authority CN]"

if [ $# -ne 1 ];
then
	echo $message
	exit 2
fi

if [ $1 = "--help" ];
then
	echo $message
	exit 2
fi

certauthCN=$1

export OPENSSL_CONF=../openssl.cnf

if [ ! -d ./ca/ ];
then
	echo "Creating folder: ca/"
	mkdir ca
	echo "Creating folder: ca/private/"
	mkdir ca/private
	echo "Creating folder: ca/certs/"
	mkdir ca/certs
	echo "Creating folder: ca/serial"
	echo "01" > ca/serial
	echo "Creating file: ca/index.txt"
	touch ca/index.txt
fi

cd ca

openssl req -x509 -newkey rsa:$strength -days $valid -out cacert.pem -outform PEM -subj /CN=$certauthCN/ -nodes

openssl x509 -in cacert.pem -out cacert.cer -outform DER

cd ..