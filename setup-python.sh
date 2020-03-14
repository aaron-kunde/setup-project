#!/bin/sh

PYTHON_VERSION=2.7.11
PYTHON_INSTALL_DIR=$HOME/opt/python-$PYTHON_VERSION

is_python_installed() {
    python --version 2>/dev/null
    test $? -eq 0
}

install_python() {
    echo "Install new python version: $PYTHON_VERSION"
    msi_file=python-$PYTHON_VERSION.msi
    
    if [ $PROCESSOR_ARCHITECTURE = "AMD64" ]; then
	msi_file=python-$PYTHON_VERSION.amd64.msi
    fi
    
    trgt_msi_file=$HOME/Downloads/$msi_file
    if [ ! -f $trgt_msi_file ]; then
	curl https://www.python.org/ftp/python/$PYTHON_VERSION/$msi_file \
	     -o $trgt_msi_file
    fi
    
    trgt_msi_file_suffix=${trgt_msi_file:2}
    python_install_dir_suffix=${PYTHON_INSTALL_DIR:2}
    msiexec //a "${trgt_msi_file:1:1}:${trgt_msi_file_suffix////\\\\}" \
	    //qb targetdir="${PYTHON_INSTALL_DIR:1:1}:${python_install_dir_suffix////\\}"
}

setup_python() {
    if [ ! -d $PYTHON_INSTALL_DIR ]; then
	echo "No Python installation found."
	install_python
    fi
    
    echo "Adding python installation $PYTHON_INSTALL_DIR to PATH"
    PATH=$PATH:$PYTHON_INSTALL_DIR
    
    echo "Adding user specific scripts to PATH"
    export PATH=$PATH:$HOME/AppData/Roaming/Python/Scripts
    export ORIGINAL_PATH="${PATH}"
}

is_pip_installed() {
    pip --version 2>/dev/null
    test $? -eq 0
}

install_and_setup_pip() {
    TRGT_PIP_INSTALL_FILE=$HOME/Downloads/get-pip.py
    
    if [ ! -f $TRGT_PIP_INSTALL_FILE ]; then
	echo "Getting installation for pip"
	curl https://bootstrap.pypa.io/get-pip.py > $TRGT_PIP_INSTALL_FILE
    fi
    
    echo "(Re-)Installing or updating pip user wide"
    python $TRGT_PIP_INSTALL_FILE --user
}


if is_python_installed; then
    echo "Python already installed"
else
    echo "Python not configured"
    setup_python
fi

if is_pip_installed; then
    echo "pip already installed"
else
    echo "pip not configured"
    install_and_setup_pip
fi

exec "$BASH" --login
