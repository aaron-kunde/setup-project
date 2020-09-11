#!/bin/sh

set -e

DEFAULT_VERSION=11.0.6+10
DEFAULT_PROVIDER=adoptopenjdk


print_usage() {
    echo "${0} [-p PROVIDER] [-v VERSION] [-i]"
    echo "  -p PROVIDER Provider for JDK binaries"
    echo "     Possible values are: oracle, openjdk or adoptopenjdk"
    echo "     Default: $DEFAULT_PROVIDER"
    echo "  -v VERSION Version of the JDK"
    echo "     Default: $DEFAULT_VERSION"
    echo "  -i Does not execute a new login shell. This can be used, to import"
    echo "     this script in other scripts"
}

oracle_export_variables() {
    version=${1}
    export JAVA_HOME="$HOME/opt/jdk$version"
    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

oracle_short_version() {
    version=${1}
    tmp=${version:2:-4}
    echo ${tmp/.0_/u}
}

oracle_check_install_file() {
    filename=${1}
    
    if [ ! -f $filename ]; then
	echo "Please download $(basename $filename) from URL to $HOME/Downloads: "
	echo -e "\nhttps://www.oracle.com/technetwork/java/javase/archive-139210.html"
	exit -1
    fi
}    

oracle_install_jdk() {
    version=${1}
    
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
    version=${1}
    echo $version | sed -ne "s/^\([0-9]\+\).*/\1/p" 
}

adoptopenjdk_export_variables() {
    version=${1}
    major_version=$(adoptopenjdk_major_version $version)

    if [ $major_version -gt 8 ]; then
	export JAVA_HOME="$HOME/opt/jdk-$version"
    else
	export JAVA_HOME="$HOME/opt/jdk$version"
    fi

    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

adoptopenjdk_short_version() {
    version=${1}
    short_version=${version/-/}

    if [ $major_version -gt 8 ]; then
	short_version=${version/+/_}
    fi
    echo $short_version
}

adoptopenjdk_download_url() {
    version="${1}"
    major_version=$(adoptopenjdk_major_version $version)
    base_url=https://github.com/AdoptOpenJDK/openjdk$major_version-binaries/releases/download
    url=$base_url/jdk$version
    
    if [ $major_version -gt 8 ]; then
	url=$base_url/jdk-$version
    fi
    echo $url
}

adoptopenjdk_install_jdk() {
    version=${1}

    if [ ! -d $JAVA_HOME ]; then       
	short_version=$(adoptopenjdk_short_version $version)
	download_dir=$HOME/Downloads
	install_file=OpenJDK11U-jdk_x64_windows_hotspot_$short_version.zip
	install_sha256_file=$install_file.sha256
	url=$(adoptopenjdk_download_url $version)
	if [ ! -f $download_dir/$install_file ]; then
	    curl -L $url/$install_file -o $download_dir/$install_file
	fi
	if [ ! -f $download_dir/$install_sha256_file ]; then
	    curl -L $url/$install_sha256_file.txt \
		 -o $download_dir/$install_sha256_file
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

openjdk_export_variables() {
    # TODO
    # version=${1}
    # major_version=$(adoptopenjdk_major_version $version)

    # if [ $major_version -gt 8 ]; then
    # 	export JAVA_HOME="$HOME/opt/jdk-$version"
    # else
    # 	export JAVA_HOME="$HOME/opt/jdk$version"
    # fi
    export JAVA_HOME="$HOME/opt/java-1.8.0-openjdk-1.8.0.151-1.b12.ojdkbuild.windows.x86_64"
    export PATH="$PATH:$JAVA_HOME/bin"
    export ORIGINAL_PATH="${PATH}"
}

openjdk_download_url() {
    # TODO
    # version="${1}"
    # major_version=$(openjdk_major_version $version)
    # base_url=https://github.com/AdoptOpenJDK/openjdk$major_version-binaries/releases/download
    # url=$base_url/jdk$version
    
    # if [ $major_version -gt 8 ]; then
    # 	url=$base_url/jdk-$version
    # fi
    # echo $url
    echo https://github.com/ojdkbuild/ojdkbuild/releases/download/1.8.0.151-1/
}

openjdk_short_version() {
    version=${1}
    short_version=${version/-/}

    if [ $major_version -gt 8 ]; then
	short_version=${version/+/_}
    fi
    echo $short_version
}


openjdk_install_jdk() {
    version=${1}

    if [ ! -d $JAVA_HOME ]; then       
	short_version=$(openjdk_short_version $version)
	download_dir=$HOME/Downloads
	# TODO: install_file=OpenJDK11U-jdk_x64_windows_hotspot_$short_version.zip
	install_file=java-1.8.0-openjdk-1.8.0.151-1.b12.ojdkbuild.windows.x86_64.zip
	install_sha256_file=$install_file.sha256
	url=$(openjdk_download_url $version)
	if [ ! -f $download_dir/$install_file ]; then
	    curl -L $url/$install_file -o $download_dir/$install_file
	fi
	if [ ! -f $download_dir/$install_sha256_file ]; then
	    # curl -L $url/$install_sha256_file.txt \
		# 	 -o $download_dir/$install_sha256_file
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

case ${provider:-$DEFAULT_PROVIDER} in
    oracle)
	DEFAULT_VERSION=1.8.0_92-b14	
	version=${version:-$DEFAULT_VERSION}
	echo "Setup Oracle JDK $version"
	oracle_export_variables $version
	oracle_install_jdk $version
	java -version
	;;
    adoptopenjdk)
	version=${version:-$DEFAULT_VERSION}
	echo "Setup AdoptOpenJDK $version"
	adoptopenjdk_export_variables $version
	adoptopenjdk_install_jdk $version
	java -version
	;;
    openjdk)
	DEFAULT_VERSION=1.8.0_151-1.b12
	version=${version:-$DEFAULT_VERSION}
	echo "Setup OpenJDK  $version"
	openjdk_export_variables $version
	openjdk_install_jdk $version
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

