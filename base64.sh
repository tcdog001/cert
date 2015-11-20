#!/bin/bash

b64() {
	local name="$1"

	cat ${name} | base64 > ${name}.base64
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
	b64 ca.key
	b64 ca.crt
	b64 server.key
	b64 server.crt
	b64 client.key
	b64 client.crt
	popd
}

main "$@"
