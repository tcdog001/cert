#!/bin/bash

prepare() {
	rm -fr demoCA
	mkdir -p ./demoCA/newcerts 
	touch demoCA/index.txt 
	touch demoCA/serial 
	echo 01 > demoCA/serial
}

do_help() {
	echo "$0 dir"
}

main() {
	local obj="$1"

	if ((1!=$#)); then
		do_help
		return 1
	elif [[ ! -d ${obj} ]]; then
		do_help
		return 1
	fi
	
	pushd ${obj}
	openssl genrsa -out ca.key 2048
	openssl req -x509 -new -nodes -key ca.key -subj "/CN=*.autelan.com" -days 5000 -out ca.crt
	openssl genrsa -out server.key 2048
	openssl req -new -key server.key -subj "/CN=*.autelan.com" -out server.csr
	openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 5000

	openssl genrsa -out client.key 2048
	openssl req -new -key client.key -subj "/CN=*.autelan.com" -out client.csr
	openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 5000

	echo extendedKeyUsage=clientAuth > client.ext
	openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile client.ext -out client.crt -days 5000
	popd

	./base64.sh ${obj}
}

main "$@"
