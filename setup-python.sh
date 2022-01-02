#!/bin/sh

set -e

VERSION=3.8.2

options() {
    while getopts hv:p: opt; do
	case $opt in
	    h) print_usage
	       exit 0
	       ;;
	    v) VERSION=$OPTARG
	       ;;
	esac	
    done
}

print_usage() {
    cat <<End-of-usage
${0} [-h] [-v VERSION]"
    -h Print this message
    -v VERSION Version  of Python
       Default: $VERSION"
End-of-usage
}

python_install_dir() {
    echo $HOME/opt/python-$VERSION
}

is_python_installed() {
    python --version 2>/dev/null && (python --version 2>&1 | grep $VERSION)
}

installer_url() {
    local filename=${1}

    echo https://www.python.org/ftp/python/$VERSION/$filename
}

trgt_installer_file() {
    echo $HOME/Downloads/${1}
}

install_python_msi() {
    local msi_file=${1}
    local trgt_msi_file=$(trgt_installer_file $msi_file)

    if [ ! -f $trgt_msi_file ]; then
	echo "ERROR: Installation file; $trgt_msi_file still not found. Something went wrong!"
	exit -1
    fi
    
    local trgt_msi_file_suffix=${trgt_msi_file:2}

    msiexec //a "${trgt_msi_file:1:1}:${trgt_msi_file_suffix////\\\\}" \
 	    //qb targetdir=$(trgt_python_install_dir)
}

trgt_python_install_dir() {
    local python_install_dir=$(python_install_dir)
    local python_install_dir_suffix=${python_install_dir:2}

    echo "${python_install_dir:1:1}:${python_install_dir_suffix////\\}"
}

install_python_exe() {
    local exe_file=${1}
    local trgt_exe_file=$(trgt_installer_file $exe_file)

    if [ ! -f $trgt_exe_file ]; then
	echo "ERROR: Installation file; $trgt_exe_file still not found. Something went wrong!"
	exit -1
    fi
     
    $trgt_exe_file /quiet SimpleInstall=1 InstallLauncherAllUsers=0 \
		   Shortcuts=0 TargetDir=$(trgt_python_install_dir)
}

file_exists_local() {
    test -f $(trgt_installer_file ${1})
}

file_exists_remote() {
    local filename=${1}
    curl -sIf $(installer_url ${filename}) >/dev/null
}

download_file() {
    local filename=${1}
    curl $(installer_url ${filename}) -o $(trgt_installer_file ${filename})
}
    
install_python() {
    echo "Install new python version: $VERSION"
    msi_file=python-$VERSION.msi
    exe_file=python-$VERSION.exe
    
    if [ $PROCESSOR_ARCHITECTURE = "AMD64" ]; then
	msi_file=python-$VERSION.amd64.msi
	exe_file=python-$VERSION-amd64.exe
    fi

    if ! file_exists_local $msi_file; then
	echo "MSI installation file $msi_file not found local. Fetching new one"
	if file_exists_remote $msi_file; then
	    download_file $msi_file
	else
	    echo "MSI installation file $msi_file not found remote. Trying EXE: $exe_file"
	    file_exists_local $exe_file || echo "NO"
	    if ! file_exists_local $exe_file; then
		echo "EXE installation file $exe_file not found local. Fetching new one"
		if file_exists_remote $exe_file; then
		    download_file $exe_file
		else
		    echo "ERROR: No installation file found. Abort"
		    exit -1
		fi
	    else
		install_python_exe $exe_file
	    fi
	fi
    else
	install_python_msi $msi_file
    fi
}

install_and_setup_python() {
    if [ ! -d $(python_install_dir) ]; then
	echo "No Python installation found."
	install_python
    fi

    echo "Adding python installation $(python_install_dir) to PATH"
    PATH=$PATH:$(python_install_dir)

    echo "Adding user specific scripts to PATH"
    export PATH=$PATH:$HOME/AppData/Roaming/Python/Scripts
    export ORIGINAL_PATH="${PATH}"
}

is_pip_installed() {
    pip --version 2>/dev/null
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

while getopts v: opt; do
    case $opt in
	v) VERSION=$OPTARG
	   ;;
    esac
done

if is_python_installed; then
    echo "Python already installed"
else
    echo "Python not configured"
    install_and_setup_python
fi

if is_pip_installed; then
    echo "pip already installed"
else
    echo "pip not configured"
    install_and_setup_pip
fi

exec "$BASH" --login
