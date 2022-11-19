#!/bin/sh

default_version=11.0.9.1+1
default_provider=adoptopenjdk


print_usage() {
    echo "${0} [-p PROVIDER] [-v VERSION]"
    echo "  -p PROVIDER Provider for JDK binaries"
    echo "     Possible values are: oracle, openjdk or adoptopenjdk"
    echo "     Default: $default_provider"
    echo "  -v VERSION Version of the JDK"
    echo "     Default: $default_version"
}

oracle_export_variables() {
    local version=${1}
    export JAVA_HOME="$HOME/opt/jdk$version"
    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

oracle_short_version() {
    local version=${1}
    local tmp=${version:2:-4}
    echo ${tmp/.0_/u}
}

oracle_check_install_file() {
    local filename=${1}
    
    if [ ! -f $filename ]; then
	echo "Please download $(basename $filename) from URL to $HOME/Downloads: "
	echo -e "\nhttps://www.oracle.com/technetwork/java/javase/archive-139210.html"
	return -1
    fi
}    

oracle_install_jdk() {
    local version=${1}
    
    if [ ! -d $JAVA_HOME ]; then
	local short_version=$(oracle_short_version $version)
	local download_dir=$HOME/Downloads
    	local install_file=$download_dir/jdk-$short_version-windows-x64.exe
    	oracle_check_install_file $install_file
	
    	local sdk_src_file=$download_dir/jdk-$short_version-linux-x64.tar.gz
    	oracle_check_install_file $sdk_src_file
	
	# Installing binaries
	local tmp_dir=$(mktemp -d)
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
    local version=${1}
    echo $version | sed -ne "s/^\([0-9]\+\).*/\1/p" 
}

adoptopenjdk_export_variables() {
    local version=${1}
    local major_version=$(adoptopenjdk_major_version $version)

    if [ $major_version -gt 8 ]; then
	export JAVA_HOME="$HOME/opt/jdk-$version"
    else
	export JAVA_HOME="$HOME/opt/jdk$version"
    fi
    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

adoptopenjdk_short_version() {
    local version=${1}
    local major_version=$(adoptopenjdk_major_version $version)

    if [ $major_version -gt 8 ]; then
	echo $version | sed -ne 's/\+/_/gp'
    else
	echo $version | tr -d '-'
    fi 
}

adoptopenjdk_download_url() {
    local version=${1}
    local major_version=$(adoptopenjdk_major_version $version)
    local base_url=https://github.com/AdoptOpenJDK/openjdk$major_version-binaries/releases/download
    
    if [ $major_version -gt 8 ]; then
	echo $base_url/jdk-$version
    else
	echo $base_url/jdk$version
    fi
}

adoptopenjdk_install_file() {
    local version=${1}
    local short_version=$(adoptopenjdk_short_version $version)       

    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo OpenJDK11U-jdk_x64_windows_hotspot_$short_version.zip
	    ;;
	*)
	    echo OpenJDK11U-jdk_x64_linux_hotspot_$short_version.tar.gz
	    ;;
    esac
}

adoptopenjdk_install_binaries() {
    local install_file=${1}
    mkdir -p $JAVA_HOME
    
    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    unzip $install_file -d $(dirname $JAVA_HOME)
	    ;;
	*)
	    tar zxf $install_file -C $(dirname $JAVA_HOME)
	    ;;
    esac


}

adoptopenjdk_install_jdk() {
    local version=${1}

    if [ ! -d $JAVA_HOME ]; then       
	local short_version=$(adoptopenjdk_short_version $version)       
	local install_file=$(adoptopenjdk_install_file $version)
	local install_sha256_file=$install_file.sha256
	local url=$(adoptopenjdk_download_url $version)

	if [ ! -f /tmp/$install_file ]; then
	    curl -L $url/$install_file -o /tmp/$install_file
	fi
	if [ ! -f /tmp/$install_sha256_file ]; then
	    curl -L $url/$install_sha256_file.txt \
		 -o /tmp/$install_sha256_file
	fi
	local pwd=$PWD
	cd /tmp
	sha256sum -c $install_sha256_file
	cd $pwd
	
	adoptopenjdk_install_binaries /tmp/$install_file
	
    else
	echo "Directory $JAVA_HOME already exists. Skipping installation"
    fi
}

openjdk_export_variables() {
    local version=${1}
    local version_number=$(openjdk_version_number $version)
    local version_number=$(java_version_number $version)
    local version_short=$(openjdk_version_short $version)

    export JAVA_HOME="$HOME/opt/java-$version_number-openjdk-$version_short.ojdkbuild.windows.x86_64"
    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

openjdk_version_number() {
    local version=${1}

    echo $version | sed -ne 's/\(\([0-9]\+\.\?\)\+\).*/\1/p'
}

java_version_number() {
    local version=${1}

    echo $version | sed -ne 's/\([0-9]\+\.[0-9]\.[0-9]\).*/\1/p'
}

openjdk_version_short() {
    local version=${1}

    echo $version | sed -ne 's/_/./g;s/-ojdkbuild-/./p'
}

openjdk_install_file() {
    local version=${1}
    local version_number=$(java_version_number $version)
    local version_short=$(openjdk_version_short $version)

    echo java-$version_number-openjdk-$version_short.ojdkbuild.windows.x86_64.zip
}

openjdk_install_dir() {
    local version=${1}
    local version_number=$(java_version_number $version)
    local version_short=$(openjdk_version_short $version)

    echo java-$version_number-openjdk-$version_short.ojdkbuild.windows.x86_64
}


openjdk_java_version_short() {
    local version=${1}
    
    echo $version | sed -ne 's/\(.*\)-ojdkbuild-.*/\1/p'
}

openjdk_download_url() {
    local version="${1}"
    local java_version=$(openjdk_java_version_short $version)

    echo https://github.com/ojdkbuild/ojdkbuild/releases/download/$java_version/
}


openjdk_install_jdk() {
    local version=${1}

    if [ ! -d $JAVA_HOME ]; then       
	local version_number=$(openjdk_version_number $version)
	local download_dir=$HOME/Downloads

	local install_file=$(openjdk_install_file $version)
	local install_sha256_file=$install_file.sha256
	local url=$(openjdk_download_url $version)

	if [ ! -f $download_dir/$install_file ]; then
	    curl -v -L $url/$install_file -o $download_dir/$install_file
	fi
	if [ ! -f $download_dir/$install_sha256_file ]; then
	    echo "1905ea74b79d6d1d2ea2b2b6887c14770f090fbb8b46e7e1bfb56e92845e9cf2 *$install_file" >  $download_dir/$install_sha256_file
	fi
	pushd $download_dir
	sha256sum -c $install_sha256_file
	popd
	
	# Installing binaries
	unzip $download_dir/$install_file -d $(dirname $JAVA_HOME)
    else
	echo "Directory $JAVA_HOME already exists. Skipping installation"
    fi
}


while getopts v:p: opt; do
    case $opt in
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
	oracle_export_variables $version
	oracle_install_jdk $version
	java -version
	;;
    adoptopenjdk)
	version=${version:-$default_version}
	echo "Setup AdoptOpenJDK $version"
	adoptopenjdk_export_variables $version
	adoptopenjdk_install_jdk $version
	java -version
	;;
    openjdk)
	default_version=1.8.0_151-1-ojdkbuild-b12
	version=${version:-$default_version}
	echo "Setup OpenJDK  $version"
	openjdk_export_variables $version
	openjdk_install_jdk $version
	java -version
	;;
    *)
	echo "ERROR: Wrong provider"
	print_usage
	return -1
esac
