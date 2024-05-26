#!/bin/bash
set -eux
PAGES_PATH="target/gh-pages"
PPA_PATH="$PAGES_PATH/deb"
DEBIAN_PACKAGE_PATH="target/debian"


ln -s /root/.cargo $HOME/.cargo
ln -s /root/.rustup $HOME/.rustup

cd $GITHUB_WORKSPACE

# Build with cargo
cargo build --verbose
cargo test --verbose
cargo deb --verbose

# Debug
export

# Create PPA
echo "$INPUT_GPG_PRIVATE_KEY" | gpg --import
mkdir -p $PPA_PATH 2>/dev/null

cp ${DEBIAN_PACKAGE_PATH}/*.deb $PPA_PATH/
cp ppa-deployment-key.pub $PPA_PATH/KEY.gpg

cd $PPA_PATH || exit

dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages

apt-ftparchive release . > Release

gpg --default-key "${INPUT_EMAIL}" --clearsign -o - Release > InRelease
gpg --default-key "${INPUT_EMAIL}" -abs -o - Release > Release.gpg
gpg --armor --export "${INPUT_EMAIL}" > KEY.gpg


# TODO: create PPA
find