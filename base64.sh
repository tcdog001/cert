#!/bin/bash

b64() {
	local name="$1"

	cat ${name} | base64 > ${name}.base64
}

do_help() {
        echo "$0 dir"
}

main() {
	local oem="$1"
	local obj="$2"

        if ((2!=$#)); then
		do_help
		return 1
	elif [[ ! -d ${oem}/${obj} ]]; then
		do_help
		return 1
	fi

	pushd ${oem}/${obj}
	b64 ca.key
	b64 ca.crt
	b64 server.key
	b64 server.crt
	b64 client.key
	b64 client.crt
	popd
}

main "$@"
