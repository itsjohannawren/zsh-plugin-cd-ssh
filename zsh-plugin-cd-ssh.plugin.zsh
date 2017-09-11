#!/usr/bin/env bash

OPENSSH_CLIENT_FLAGS="1246AaCfGgKkMNnqsTtVvXxYy"
OPENSSH_CLIENT_PARAMS="bcDEeFIiJLlmOopQRSWw"

_sshGetHostname() {
	local SSH_CLIENT_FLAGS SSH_CLIENT_PARAMS

	if ssh -V 2>&1 | grep -qi 'OpenSSH'; then
		SSH_CLIENT_FLAGS="${OPENSSH_CLIENT_FLAGS}"
		SSH_CLIENT_PARAMS="${OPENSSH_CLIENT_PARAMS}"
	else
		echo "Notice: Unknown SSH client" 1>&2
		return 1
	fi

	while [ "${#}" != "0" ]; do
		if grep -qE "^[${SSH_CLIENT_FLAGS}]\$" <<<"${1:1}"; then
			shift &>/dev/null
		elif grep -qE "^[${SSH_CLIENT_PARAMS}]\$" <<<"${1:1}"; then
			shift &>/dev/null
			shift &>/dev/null
		elif grep -q '@' <<<"${1}"; then
			cut -d '@' -f 2 <<<"${1}"
			return 0
		else
			echo "${1}"
			return 0
		fi
	done

	return 1
}

_isHostname() {
	host -- "${1}" &>/dev/null
	return $?
}

cd() {
	local SSH_HOSTNAME

	if [ "${#}" = "0" ] || ([ "${#}" = "1" ] && [ -d "${1}" ]) || ([ "${#}" = "1" ] && [ "${1}" = "-q" ]) || ([ "${#}" = "2" ] && [ "${1}" = "-q" ] && [ -d "${2}" ]); then
		builtin cd "${@}"
		return $?
	fi

	SSH_HOSTNAME="$(_sshGetHostname "${@}")"
	if [ "$?" != "0" ]; then
		echo "Error: The directory passed does not exist or the SSH command is malformed: ${*}" 1>&2
		return 1
	fi

	if ! _isHostname "${SSH_HOSTNAME}"; then
		echo "Error: The hostname passed does not resolve to an A or AAAA record: ${*}" 1>&2
		return 1
	fi

	echo "It looks like you meant 'ssh', not 'cd'. Let me help you with that..."

	ssh "${@}"
}
