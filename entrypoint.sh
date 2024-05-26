#!/bin/bash
set -eux

ln -s /root/.cargo $HOME/.cargo
ln -s /root/.rustup $HOME/.rustup

cd $GITHUB_WORKSPACE

/root/.cargo/bin/cargo build --verbose
/root/.cargo/bin/cargo test --verbose
/root/.cargo/bin/cargo deb --verbose

# TODO: create PPA
find