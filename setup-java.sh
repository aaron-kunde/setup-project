#!/bin/sh

set -e

java_version=1.8.0_92


short_version() {
    tmp=${java_version:2}
    echo ${tmp/.0_/u}
}

export_variables() {
    export JAVA_HOME="$HOME/opt/jdk$java_version"
    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

check_install_file() {
    filename=${1}
    
    if [ ! -f $filename ]; then
	echo "Please download $(basename $filename) from: "
	echo -e "\nhttps://www.oracle.com/technetwork/java/javase/archive-139210.html"
	exit -1
    fi
}    

while getopts sv: opt; do
    case $opt in
	s) skip_exec_bash=true
	   ;;
	v) java_version=$OPTARG
	   ;;
    esac
done

export_variables

if [ ! -d $JAVA_HOME ]; then
    install_file="$HOME/Downloads/jdk-$(short_version $java_version)-windows-x64.exe"
    check_install_file $install_file
      
    sdk_src_file="$HOME/Downloads/jdk-$(short_version $java_version)-linux-x64.tar.gz"
    check_install_file $sdk_src_file

    # Installing binaries
    tmp_dir=$(mktemp -d)
    7z -o$tmp_dir x $install_file
    unzip $tmp_dir/tools.zip -d $JAVA_HOME
    rm -rf $tmp_dir
    find $JAVA_HOME -name '*.pack' | while IFS= read filename; do $JAVA_HOME/bin/unpack200.exe -r $filename ${filename::-4}jar; done;

    # Adding sources
    tar zvxf $sdk_src_file -C "$HOME/opt" $(basename $JAVA_HOME)/src.zip 
fi

if [ ! $skip_exec_bash ]; then
    exec "$BASH" --login -i
fi

