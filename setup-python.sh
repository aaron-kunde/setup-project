#!/bin/sh

PYTHON_VERSION=2.7.11
PYTHON_INSTALL_DIR=$HOME/opt/python-$PYTHON_VERSION

echo "Step 1: Checking Python installation"
python --version 2>/dev/null

if [ $? -eq 0 ]; then  
    echo "Python already installed"
else
    if [ ! -d $PYTHON_INSTALL_DIR ]; then
	echo "No Python installation found."
	echo "Install new python version: $PYTHON_VERSION"
	MSI_FILE=python-$PYTHON_VERSION.msi
	MSI_MD5=241bf8e097ab4e1047d9bb4f59602095
    
	if [ $PROCESSOR_ARCHITECTURE = "AMD64" ]; then
	    MSI_FILE=python-$PYTHON_VERSION.amd64.msi
	    MSI_MD5=25acca42662d4b02682eee0df3f3446d
	fi
    
	TRGT_MSI_FILE=$HOME/Downloads/$MSI_FILE
	md5sum $TRGT_MSI_FILE | grep -qe $MSI_MD5 || 
	    curl https://www.python.org/ftp/python/$PYTHON_VERSION/$MSI_FILE \
		 -o $TRGT_MSI_FILE &&
		md5sum $TRGT_MSI_FILE | grep -qe $MSI_MD5
	
	TRGT_MSI_FILE_SUFFIX=${TRGT_MSI_FILE:2}
	PYTHON_INSTALL_DIR_SUFFIX=${PYTHON_INSTALL_DIR:2}
	msiexec //a "${TRGT_MSI_FILE:1:1}:${TRGT_MSI_FILE_SUFFIX////\\\\}" \
		//qb TARGETDIR="${PYTHON_INSTALL_DIR:1:1}:${PYTHON_INSTALL_DIR_SUFFIX////\\}"
    fi

    echo "Adding python installation $PYTHON_INSTALL_DIR to PATH"
    PATH=$PATH:$PYTHON_INSTALL_DIR
    
    echo "Adding user specific scripts to PATH"
    export PATH=$PATH:$HOME/AppData/Roaming/Python/Scripts
    export ORIGINAL_PATH="${PATH}"
fi

echo "Step2: Checking pip installing"
pip --version 2>/dev/null

if [ $? -eq 0 ]; then
    echo "pip already installed"
else
    echo "No installation of pip found"
    TRGT_PIP_INSTALL_FILE=$HOME/Downloads/get-pip.py

    if [ ! -f $TRGT_PIP_INSTALL_FILE ]; then
	echo "Getting installation for pip"
	curl https://bootstrap.pypa.io/get-pip.py > $TRGT_PIP_INSTALL_FILE
    fi
    
    echo "(Re-)Installing or updating pip user wide"
    python $TRGT_PIP_INSTALL_FILE --user
fi

exec "$BASH" --login
