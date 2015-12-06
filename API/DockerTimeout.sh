#!/bin/bash

set -e

to=$1
shift

os=$(uname -a | cut -d " " -f 1)

# if linux, using timeout, if Mac, use gtimeout (use `brew install coreutils` to install gtimeout)
if [ $os = 'Darwin' ]
then
    timeout="gtimeout"
else
    timeout="timeout"
fi

cont=$(docker run -d "$@")
code=$("$timeout" "$to" docker wait "$cont" || true)
docker kill $cont &> /dev/null
echo -n 'status: '
if [ -z "$code" ]; then
    echo timeout
else
    echo exited: $code
fi

echo output:
# pipe to sed simply for pretty nice indentation
docker logs $cont | sed 's/^/\t/'

docker rm $cont &> /dev/null
