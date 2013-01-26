#!/bin/bash

hr="-------------------------------------------"
br=""
strength=2048
valid=365	

message="Usage:  sh create_client_cert.sh [client name] [PKCS12 password]"

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

cname=$1
password=$2

export OPENSSL_CONF=../openssl.cnf

if [ ! -d ./client/ ];
then
	echo "Creating folder: client/"
	mkdir client
fi

cd client

echo "Generating key.pem"

openssl genrsa -out $cname.key.pem $strength

echo "Generating req.pem"

openssl req -new -key $cname.key.pem -out $cname.req.pem -outform PEM -subj /CN=$cname/O=client/ -nodes

cd ../ca

echo "Generating cert.pem"

openssl ca -in ../client/$cname.req.pem -out ../client/$cname.cert.pem -notext -batch -extensions client_ca_extensions

cd ../client

echo "Generating keycert.p12"

openssl pkcs12 -export -out $cname.keycert.p12 -in $cname.cert.pem -inkey $cname.key.pem -passout pass:$password