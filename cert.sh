#!/bin/bash

prepare() {
	rm -fr demoCA
	mkdir -p ./demoCA/newcerts 
	touch demoCA/index.txt 
	touch demoCA/serial 
	echo 01 > demoCA/serial
}

do_help() {
	echo "$0 oem obj"
}

get_domain() {
	local oem="$1"
	local obj="$2"
	local domain

	case ${oem} in
	raytight)
		domain="raytight.com"
		;;
	deft|*)
		domain="autelan.com"
		;;
	esac

	echo ${domain}
}

get_bits() {
        local oem="$1"
        local obj="$2"
        local bits=2048

	if [[ "lss" == "${obj}" ]]; then
		bits=4096
	fi

        echo ${bits}
}

main() {
	local oem="$1"
	local obj="$2"
	local domain

	if ((2!=$#)); then
		do_help
		return 1
	elif [[ ! -d ${oem}/${obj} ]]; then
		do_help
		return 1
	fi

	local domain=$(get_domain ${oem} ${obj})
	local days=7300
	local bits=$(get_bits ${oem} ${obj})

	echo "domain=${domain}"
	echo "days=${days}"
	echo "bits=${bits}"

	pushd ${oem}/${obj}
	openssl genrsa -out ca.key ${bits}
	openssl req -x509 -new -nodes -key ca.key -subj "/CN=*.${domain}" -days ${days} -out ca.crt
	openssl genrsa -out server.key ${bits}
	openssl req -new -key server.key -subj "/CN=*.${domain}" -out server.csr
	openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days ${days}

	openssl genrsa -out client.key ${bits}
	openssl req -new -key client.key -subj "/CN=*.ltefi.com" -out client.csr
#	openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days 5000
	echo extendedKeyUsage=clientAuth > client.ext
	openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile client.ext -out client.crt -days ${days}
	popd

	./base64.sh ${oem} ${obj}
	./c.sh ${oem} ${obj}
}

main "$@"
