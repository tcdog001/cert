#!/bin/bash

c() {
	local name="$1"
	local line

	rm -f ${name}.c
	while read line; do
		echo "    \"${line}\" \\" >> ${name}.c
	done < ${name}.base64
}

do_help() {
        echo "$0 oem dir"
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
	c ca.key
	c ca.crt
	c server.key
	c server.crt
	c client.key
	c client.crt
	popd
}

main "$@"
