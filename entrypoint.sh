#!/bin/bash
set -eux
PAGES_PATH="target/gh-pages"
PPA_PATH="$PAGES_PATH/deb"
DEBIAN_PACKAGE_PATH="target/debian"
PACKAGE_NAME=$(cat Cargo.toml | toml2json | jq -r .package.name)


ln -s /root/.cargo $HOME/.cargo
ln -s /root/.rustup $HOME/.rustup

cd $GITHUB_WORKSPACE

# Build with cargo
cargo build --verbose
cargo test --verbose
cargo deb --verbose
cargo doc

# Add doc to pages
cd $GITHUB_WORKSPACE
mkdir -p $PAGES_PATH
cp -rv target/doc/* $PAGES_PATH/
# Add index file with forwarding
echo '<meta http-equiv="refresh" content="0; url='"$PACKAGE_NAME"'">' > $PAGES_PATH/index.html

# Build documentation
#cd $GITHUB_WORKSPACE
#mkdir -p $PAGES_PATH || true
#mkdocs build --site-dir $PAGES_PATH


# Create PPA
cd $GITHUB_WORKSPACE
echo "$INPUT_GPG_PRIVATE_KEY" | gpg --import
mkdir -p $PPA_PATH 2>/dev/null

cp ${DEBIAN_PACKAGE_PATH}/*.deb $PPA_PATH/
gpg --export-secret-keys --armor "${INPUT_EMAIL}" > $PPA_PATH/KEY.gpg

cd $PPA_PATH || exit

dpkg-scanpackages --multiversion . > Packages
gzip -k -f Packages

apt-ftparchive release . > Release

gpg --default-key "${INPUT_EMAIL}" --clearsign -o - Release > InRelease
gpg --default-key "${INPUT_EMAIL}" -abs -o - Release > Release.gpg
gpg --armor --export "${INPUT_EMAIL}" > KEY.gpg


# Set permissions
cd $GITHUB_WORKSPACE
chmod -R 777 target
