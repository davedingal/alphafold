#!/bin/bash

set -e -o pipefail

mkdir -p $HOME/.local/

wget -q -P ./alphafold/common/ https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

mkdir -p /tmp/alphafold_build
pushd /tmp/alphafold_build/

export PATH=${HOME}/.local/bin/:$PATH

# module load gcc/10.????

# build and install hmmer from source (if it isn't already in the path)
if ! which hmmstat 2>&1 > /dev/null; then
	mkdir -p hmmer
	pushd hmmer/
	curl -XGET http://eddylab.org/software/hmmer/hmmer.tar.gz | tar xzf - -C ./
	# cd into the directory that hmmer was untarred to.
	cd $(ls -1)
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
	if ! [ -d hdf5 ]; then
		git clone https://github.com/HDFGroup/hdf5.git hdf5
	fi
	pushd hdf5
	./autogen.sh
	./configure --prefix=${HOME}/.local/
	make -j 8
	make install
	popd

	if ! [ -d tldevel ]; then
		git clone https://github.com/TimoLassmann/tldevel.git tldevel
	fi
	pushd tldevel
	./autogen.sh
	./configure --prefix=${HOME}/.local/ --with-hdf5
	make -j 8
	make install
	popd

	if ! [ -d kalign ]; then
		git clone https://github.com/TimoLassmann/kalign.git kalign/
	fi
	pushd kalign/
	./autogen.sh
	./configure --prefix=${HOME}/.local/
	make -j 8
	make install
	popd
fi

#echo "This software requires python 3.7 or later to run.  Please make sure your version of python is new enough before proceeding."
#read test

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

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ./Miniconda3-latest-Linux-x86_64.sh -b -p ~/.local/conda/
rm ./Miniconda3-latest-Linux-x86_64.sh

export PATH=$HOME/.local/conda/bin/:$PATH
export PYTHONPATH=$HOME/.local/conda:$PYTHONPATH

conda update -qy conda
conda install -y -c conda-forge openmm=7.5.1 cudatoolkit=11.4 pdbfixer

pip3 install --upgrade pip
pip3 install -r requirements.txt

#Install jaxlib version compatible with TACC Cuda version 11.4
pip3 install --upgrade jaxlib==0.1.73+cuda11.cudnn82 -f https://storage.googleapis.com/jax-releases/jax_releases.html

# TACC GPU nodes use cuda v11.4 and nvcc is not installed so we have to bring our own...
conda install --force -c nvidia cuda-nvcc=11.4

#pushd $HOME/.local/lib/python3.9/site-packages/
#patch -p0 < ${WORK}
