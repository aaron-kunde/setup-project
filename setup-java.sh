#!/bin/sh

set -e

default_version=8u222-b10
default_provider=adoptopenjdk


print_usage() {
    echo "${0} [-p PROVIDER] [-v VERSION] [-i]"
    echo "  -p PROVIDER Provider for JDK binaries"
    echo "     Possible values are: oracle or adoptopenjdk"
    echo "     Default: $default_provider"
    echo "  -v VERSION Version of the JDK"
    echo "     Default: $default_version"
    echo "  -i Does not execute a new login shell. This can be used, to import"
    echo "     this script in other scripts"
}

oracle_export_variables() {
    export JAVA_HOME="$HOME/opt/jdk$version"
    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

oracle_short_version() {
    tmp=${version:2:-4}
    echo ${tmp/.0_/u}
}

oracle_check_install_file() {
    filename=${1}
    
    if [ ! -f $filename ]; then
	echo "Please download $(basename $filename) from to $HOME/Downloads: "
	echo -e "\nhttps://www.oracle.com/technetwork/java/javase/archive-139210.html"
	exit -1
    fi
}    

oracle_install_jdk() {
    if [ ! -d $JAVA_HOME ]; then
	short_version=$(oracle_short_version $version)
	download_dir=$HOME/Downloads
    	install_file=$download_dir/jdk-$short_version-windows-x64.exe
    	oracle_check_install_file $install_file
	
    	sdk_src_file=$download_dir/jdk-$short_version-linux-x64.tar.gz
    	oracle_check_install_file $sdk_src_file
	
	# Installing binaries
	tmp_dir=$(mktemp -d)
	7z -o$tmp_dir x $install_file
	unzip $tmp_dir/tools.zip -d $JAVA_HOME
	rm -rf $tmp_dir
	find $JAVA_HOME -name '*.pack' | while IFS= read filename; do $JAVA_HOME/bin/unpack200.exe -r $filename ${filename::-4}jar; done;
	
	# Adding sources
	tar zvxf $sdk_src_file --strip-components=1 -C $JAVA_HOME $(basename ${JAVA_HOME::-4})/src.zip
    else
 	echo "Directory $JAVA_HOME already exists. Skipping installation"
    fi
}


adoptopenjdk_major_version() {
    echo "${1}" | sed -ne "s/^\([0-9]\+\).*/\1/p" 
}

adoptopenjdk_export_variables() {
    major_version=$(adoptopenjdk_major_version $version)
    if [ $major_version -gt 8 ]; then
	export JAVA_HOME="$HOME/opt/jdk-$version"
    else
	export JAVA_HOME="$HOME/opt/jdk$version"
    fi

    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

adoptopenjdk_install_jdk() {
    if [ ! -d $JAVA_HOME ]; then
	short_version=${version/-/}
	download_dir=$HOME/Downloads
	install_file=$download_dir/OpenJDK8U-jdk_x64_windows_hotspot_$short_version.zip
	install_sha256_file=$install_file.sha256
	url=https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk$version
	if [ ! -f $download_dir/$install_file ]; then
	    curl -L $url/$install_file -o $install_file
	fi
	if [ ! -f $download_dir/$install_sha256_file ]; then
	    curl -L $url/$install_sha256_file.txt -o $install_sha256_file
	fi
	pushd $HOME/Downloads
	sha256sum -c $install_sha256_file
	popd
	
	# Installing binaries
	unzip $download_dir/$install_file -d $(dirname $JAVA_HOME)
    else
	echo "Directory $JAVA_HOME already exists. Skipping installation"
    fi
}

while getopts iv:p: opt; do
    case $opt in
	i) skip_exec_bash=true
	   ;;
	v) version=$OPTARG
	   ;;
	p) provider=$OPTARG
	   ;;
    esac
done

case ${provider:-$default_provider} in
    oracle)
	default_version=1.8.0_92-b14	
	version=${version:-$default_version}
	echo "Setup Oracle JDK $version"
	oracle_export_variables
	oracle_install_jdk
	java -version
	;;
    adoptopenjdk)
	version=${version:-$default_version}
	echo "Setup AdoptOpenJDK $version"
	adoptopenjdk_export_variables
	adoptopenjdk_install_jdk
	java -version
	;;
    *)
	echo "ERROR: Wrong provider"
	print_usage
	exit -1
esac
    


if [ ! $skip_exec_bash ]; then
    exec "$BASH" --login -i
fi

