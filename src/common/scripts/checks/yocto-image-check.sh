#! /bin/bash


IMAGE_NAME=$1

GET_IMAGE=$(docker images --format '{{.Repository}}' | grep -- "$IMAGE_NAME")
if [[ -z $GET_IMAGE ]]; then
	echo "Build ENV IMAGE first!"
	exit 1
fi

