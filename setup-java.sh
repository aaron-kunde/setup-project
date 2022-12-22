init_global_vars() {
    DEFAULT_VERSION=11.0.9.1+1
    VERSION=$DEFAULT_VERSION
    DEFAULT_PROVIDER=adoptopenjdk
    INSTALLATION_BASE_DIR=$HOME/opt
    OPTIND=1
}

print_usage() {
    cat <<EOM
${0} [-v VERSION] [-p PROVIDER]
  -v VERSION Version of the JDK
     Default: $DEFAULT_VERSION
  -p PROVIDER Provider for JDK binaries
     Possible values are: oracle, openjdk or adoptopenjdk
     Default: $DEFAULT_PROVIDER
EOM
}

reset_path_vars() {
    if [ -v SETUP_JAVA_ORIGINAL_PATH ]; then
	export PATH="${SETUP_JAVA_ORIGINAL_PATH}"
	unset SETUP_JAVA_ORIGINAL_PATH
    fi
}

reset_global_vars() {
    unset DEFAULT_VERSION
    unset VERSION
    unset DEFAULT_PROVIDER
    unset PROVIDER
    OPTIND=1

}

abort() {
    reset_path_vars
    reset_global_vars

    return 0
}

is_installed() {
    java -version 2>/dev/null &&
	(java -version 2>&1 | grep $VERSION)
}

oracle_export_variables() {
    export JAVA_HOME="$HOME/opt/jdk$VERSION"
    SETUP_JAVA_ORIGINAL_PATH="${PATH}"
    export PATH="$PATH:$JAVA_HOME/bin"
}

oracle_short_version() {
    local tmp=${VERSION:2:-4}
    echo ${tmp/.0_/u}
}

oracle_check_install_file() {
    local filename=${1}
    
    if [ ! -f $filename ]; then
	echo "Please download $(basename $filename) from URL to $HOME/Downloads: "
	echo -e "\nhttps://www.oracle.com/technetwork/java/javase/archive-139210.html"
	abort
    fi
}    

oracle_install_jdk() {
    local short_version=$(oracle_short_version)
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
}

adoptopenjdk_major_version() {
    local ret=$(echo $VERSION | sed -ne "s/^\([0-9]\+\).*/\1/p")

    if [ -z $ret ]; then
	echo -1
    else
	echo $ret
    fi 
}

adoptopenjdk_export_variables() {
    local major_version=$(adoptopenjdk_major_version)

    if [ $major_version -gt 8 ]; then
	export JAVA_HOME="$HOME/opt/jdk-$VERSION"
    else
	export JAVA_HOME="$HOME/opt/jdk$VERSION"
    fi
    SETUP_JAVA_ORIGINAL_PATH="${PATH}"
    export PATH="$PATH:$JAVA_HOME/bin"
}

adoptopenjdk_short_version() {
    local major_version=$(adoptopenjdk_major_version)

    if [ $major_version -gt 8 ]; then
	echo $VERSION | sed -ne 's/\+/_/gp'
     else
	 echo $VERSION | tr -d '-'
    fi
}

adoptopenjdk_file_exists_remote() {
    curl -sIf $(adoptopenjdk_download_url) >/dev/null
}

adoptopenjdk_download_url() {
    local major_version=$(adoptopenjdk_major_version)
    local base_url=https://github.com/AdoptOpenJDK/openjdk$major_version-binaries/releases/download
    
    if [ $major_version -gt 8 ]; then
	echo $base_url/jdk-$VERSION
    else
	echo $base_url/jdk$VERSION
    fi
}

adoptopenjdk_install_file() {
    local short_version=$(adoptopenjdk_short_version)       

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
    local short_version=$(adoptopenjdk_short_version)       
    local install_file=$(adoptopenjdk_install_file)
    local install_sha256_file=$install_file.sha256
    local url=$(adoptopenjdk_download_url)
    
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
}

openjdk_export_variables() {
    local version_number=$(java_version_number)
    local version_short=$(openjdk_version_short)

    export JAVA_HOME="$HOME/opt/java-$version_number-openjdk-$version_short.ojdkbuild.windows.x86_64"
    SETUP_JAVA_ORIGINAL_PATH="${PATH}"
    export PATH="$PATH:$JAVA_HOME/bin"
}

openjdk_version_number() {
    echo $VERSION | sed -ne 's/\(\([0-9]\+\.\?\)\+\).*/\1/p'
}

java_version_number() {
    echo $VERSION | sed -ne 's/\([0-9]\+\.[0-9]\.[0-9]\).*/\1/p'
}

openjdk_version_short() {
    echo $VERSION | sed -ne 's/_/./g;s/-ojdkbuild-/./p'
}

openjdk_install_file() {
    local version_number=$(java_version_number)
    local version_short=$(openjdk_version_short)

    echo java-$version_number-openjdk-$version_short.ojdkbuild.windows.x86_64.zip
}

openjdk_install_dir() {
    local version_number=$(java_version_number)
    local version_short=$(openjdk_version_short)

    echo java-$version_number-openjdk-$version_short.ojdkbuild.windows.x86_64
}

openjdk_java_version_short() {
    echo $VERSION | sed -ne 's/\(.*\)-ojdkbuild-.*/\1/p'
}

openjdk_download_url() {
    local java_version=$(openjdk_java_version_short)

    echo https://github.com/ojdkbuild/ojdkbuild/releases/download/$java_version/
}

openjdk_install_jdk() {
    local version_number=$(openjdk_version_number)
    local download_dir=/tmp
    
    local install_file=$(openjdk_install_file)
    local install_sha256_file=$install_file.sha256
    local url=$(openjdk_download_url)
    
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
}

init_global_vars
reset_path_vars

while getopts v:p: opt; do
    case $opt in
	v) VERSION=$OPTARG
	   ;;
	p) PROVIDER=$OPTARG
	   ;;
    esac
done

case ${PROVIDER:-$DEFAULT_PROVIDER} in
    oracle)
	DEFAULT_VERSION=1.8.0_92-b14
	VERSION=${VERSION:-$DEFAULT_VERSION}
	echo "Setup Oracle JDK $VERSION"
	oracle_export_variables
	if is_installed; then
	    echo "Oracle JDK already installed"
	else
	    echo "Oracle JDK not configured"
	    oracle_install_jdk
	fi
	java -version
	;;
    adoptopenjdk)
	VERSION=${VERSION:-$DEFAULT_VERSION}
	echo "Setup AdoptOpenJDK $VERSION"
	adoptopenjdk_export_variables
	if is_installed; then
	    echo "AdoptOpenJDK already installed"
	else
	    echo "AdoptOpenJDK not configured"
	    adoptopenjdk_install_jdk
	fi
	java -version
	;;
    openjdk)
	DEFAULT_VERSION=1.8.0_151-1-ojdkbuild-b12
	VERSION=${VERSION:-$DEFAULT_VERSION}
	echo "Setup OpenJDK $VERSION"
	openjdk_export_variables
	if is_installed; then
	    echo "OpenJDK already installed"
	else
	    echo "OpenJDK not configured"
	    openjdk_install_jdk
	fi
	java -version
	;;
    *)
	echo "ERROR: Wrong provider:$PROVIDER"
	print_usage
	abort
esac

reset_global_vars
