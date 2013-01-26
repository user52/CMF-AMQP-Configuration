#!/bin/bash

hr="-------------------------------------------"
br=""
strength=2048
valid=365	

message="Usage:  sh make_server_cert.sh [server name] [PKCS12 password]"

if [ $# -ne 2 ];
then
	echo $message
	exit 2
fi

if [ $1 = "--help" ];
then
	echo $message
	exit 2
fi

sname=$1
password=$2

export OPENSSL_CONF=../openssl.cnf

if [ ! -d ./server/ ];
then
	echo "Creating Server folder: server/"
	mkdir server
fi

cd server

echo "Generating key.pem"

openssl genrsa -out $sname.key.pem $strength

echo "Generating req.pem"

openssl req -new -key $sname.key.pem -out $sname.req.pem -outform PEM -subj /CN=$sname/O=server/ -nodes

cd ../ca

echo "Generating cert.pem"

openssl ca -in ../server/$sname.req.pem -out ../server/$sname.cert.pem -notext -batch -extensions server_ca_extensions

cd ../server

echo "Generating keycert.p12"

openssl pkcs12 -export -out $sname.keycert.p12 -in $sname.cert.pem -inkey $sname.key.pem -passout pass:$password

cd ..