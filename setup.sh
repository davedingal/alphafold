#!/bin/bash

set -e -o pipefail

pushd ~
mkdir -p .local/
popd

mkdir -p /tmp/alphafold_build
pushd /tmp/alphafold_build/

# module load gcc/10.????

# build and install hmmer from source (if it isn't already in the path)
if ! which hmmstat 2>&1 > /dev/null; then
	mkdir -p hmmer
	pushd hmmer/
	curl -XGET http://eddylab.org/software/hmmer/hmmer.tar.gz | tar xzf /dev/stdin -C ./
	./configure --prefix=${HOME}/.local/
	make -j 8
	make install
	popd
fi

# same thing for hhsuite
if ! which hhblits 2>&1 > /dev/null; then
	git clone --branch v3.3.0 https://github.com/soedinglab/hh-suite.git hhsuite/
	mkdir -p hhsuite/build/
	pushd hhsuite/build/
	cmake -DCMAKE_INSTALL_PREFIX=${HOME}/.local/ ../
	make -j 8
	make install
	popd
fi

if ! which kalign 2>&1 > /dev/null; then
	git clone https://github.com/HDFGroup/hdf5.git hdf5
	pushd hdf5
	./autogen.sh
	./configure --prefix=${HOME}/.local/
	make -j 8
	make install
	popd

	git clone https://github.com/TimoLassmann/tldevel.git tldevel
	pushd tldevel
	./autogen.sh
	./configure --prefix=${HOME}/.local/ --width-hdf5
	make -j 8
	make install
	popd

	git clone https://github.com/TimoLassmann/kalign.git kalign/
	pushd kalign/
	./autogen.sh
	./configure --prefix=${HOME}/.local/
	make -j 8
	make install
	popd
fi

echo "This software requires python 3.7 or later to run.  Please make sure your version of python is new enough before proceeding."
read test

# to build ptyhon using a locally built (and installed) copy of libffi, set CFLAGS, CPPFLAGS, LDFLAGS, and LD_LIBRARY_PATH appropriately before using pyenv to install a new version of python

# export CFLAGS=-I$HOME/.local/include/
# export CPPFLAGS=-I$HOME/.local/include/
# export LDFLAGS=-L$HOME/.local/lib64/
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.local/lib64/

# CONFIGURE_OPTS="--with-system-ffi" pyenv install 3.9.6

# if not, then:
# install pyenv
# install libffi from source
# CONFIGURE_OPTS="--with-system-ffi" pyenv install 3.9.6
# pyenv global 3.9.6
# pip install -r requirements.txt
