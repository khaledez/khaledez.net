#! /bin/sh
set -ex

HUB_VERSION=2.12.3

apk add --update --no-cache bash openssh libc6-compat git

mkdir /opt/hub

wget -O hub.tgz https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-amd64-$HUB_VERSION.tgz
tar -xvf hub.tgz -C /opt/hub --strip-components 1

alias git=hub
bash /opt/hub/install
hub --version
#=========== Clenaup ===========
rm -v hub.tgz