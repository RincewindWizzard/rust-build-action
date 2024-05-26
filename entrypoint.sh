#!/bin/bash
set -eux

ln -s /root/.cargo $HOME/.cargo
ln -s /root/.rustup $HOME/.rustup

cd $GITHUB_WORKSPACE

cargo build --verbose
cargo test --verbose
cargo deb --verbose

# TODO: create PPA
find