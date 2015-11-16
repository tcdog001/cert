#!/bin/bash

prepare() {
	rm -fr demoCA
	mkdir -p ./demoCA/newcerts 
	touch demoCA/index.txt 
	touch demoCA/serial 
	echo 01 > demoCA/serial
}

openssl genrsa -des3 -out server.key 1024
openssl rsa -in server.key -out server.key
openssl req -new -key server.key -out server.csr -config openssl.cnf

openssl genrsa -des3 -out client.key 1024
openssl rsa -in client.key -out client.key
openssl req -new -key client.key -out client.csr -config openssl.cnf

openssl req -new -x509 -keyout ca.key -out ca.crt -config openssl.cnf
openssl rsa -in ca.key -out ca.key

prepare
openssl ca -in server.csr -out server.crt -cert ca.crt -keyfile ca.key -config openssl.cnf
prepare
openssl ca -in client.csr -out client.crt -cert ca.crt -keyfile ca.key -config openssl.cnf

