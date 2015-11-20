#!/bin/bash

prepare() {
	rm -fr demoCA
	mkdir -p ./demoCA/newcerts 
	touch demoCA/index.txt 
	touch demoCA/serial 
	echo 01 > demoCA/serial
}

b64() {
	local name="$1"

	cat ${name} | base64 > ${name}.base64
}

main() {
	openssl genrsa -out ca.key 2048
	openssl req -x509 -new -nodes -key ca.key -subj "/CN=*.pepfi.com" -days 5000 -out ca.crt
	openssl genrsa -out server.key 2048
	openssl req -new -key server.key -subj "/CN=*.pepfi.com" -out server.csr
	openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 5000

	openssl genrsa -out client.key 2048
	openssl req -new -key client.key -subj "/CN=*.ltefi.com" -out client.csr
	openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 5000

	echo extendedKeyUsage=clientAuth > client.ext
	openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile client.ext -out client.crt -days 5000

	b64 ca.key
	b64 ca.crt
	b64 server.key
	b64 server.crt
	b64 client.key
	b64 client.crt
}

main "$@"
