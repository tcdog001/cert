#!/bin/bash

prepare() {
	rm -fr demoCA
	mkdir -p ./demoCA/newcerts 
	touch demoCA/index.txt 
	touch demoCA/serial 
	echo 01 > demoCA/serial
}

private() {
	local name="$1"

	openssl genrsa -des3 -out ${name}.key 1024
	openssl rsa -in ${name}.key -out ${name}.key
	cat ${name}.key | base64 > ${name}.key.base64

	openssl req -new -key ${name}.key -out ${name}.csr -config openssl.cnf
	cat ${name}.csr | base64 > ${name}.csr.base64
}

cert() {
	local name="$1"

	prepare
	openssl ca -in ${name}.csr -out ${name}.crt -cert ca.crt -keyfile ca.key -config openssl.cnf
	cat ${name}.crt | base64 > ${name}.crt.base64
}

main() {
	private server
	private client

	openssl req -new -x509 -keyout ca.key -out ca.crt -config openssl.cnf
	openssl rsa -in ca.key -out ca.key
	cat ca.key | base64 > ca.key.base64
	cat ca.crt | base64 > ca.crt.base64

	cert server
	cert client
}

main "$@"
