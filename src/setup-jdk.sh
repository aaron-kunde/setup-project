#!/bin/sh
__sp_init_global_vars() {
    __sp_version=$(__sp_default_version)
    __sp_installation_base_dir=$HOME/opt
    # Reset OPTIND, if getopts was used before
    OPTIND=1
}
__sp_reset_custom_vars_and_funcs() {
    unset $(declare | grep '^__sp_' | tr '=' ' ' | cut -f1 -d ' ')
    # Reset OPTIND for future use of getopts
    OPTIND=1
}
__sp_set_vars_from_opts() {
    while getopts v: opt; do
	case $opt in
	    v) __sp_version=$OPTARG
	       ;;
	esac
    done
}
__sp_abort() {
    __sp_restore_exported_vars

    return 0
}
__sp_local_installation_file_path() {
    echo /tmp/$(__sp_installation_file)
}
__sp_remote_installation_file_exists() {
    curl -sIf $(__sp_download_url) >/dev/null
}
__sp_download_installation_file() {
    echo "Download installation file"
    curl -L $(__sp_download_url) -o $(__sp_local_installation_file_path)
}
__sp_install() {
    echo "Install version: $__sp_version"

    if [ ! -f $(__sp_local_installation_file_path) ]; then
	echo "Local installation file not found: $(__sp_local_installation_file_path). Try, download new one"
	if __sp_remote_installation_file_exists; then
	    __sp_download_installation_file
	else
	    echo "ERROR: No remote installation file found. Abort"
	    __sp_abort
	fi
    fi
    __sp_install_installation_file
 }
__sp_main() {
    __sp_init_global_vars
    __sp_set_vars_from_opts ${@}

    if ! __sp_is_installed; then
	echo "Start installation"
	__sp_restore_exported_vars
	__sp_export_vars
	__sp_install || __sp_abort
    fi

    __sp_print_success_message
    __sp_reset_custom_vars_and_funcs
}

__sp_default_version() {
    echo 21.0.1+12
}
__sp_jdk_major_version() {
    echo $__sp_version | sed -ne "s/^\([0-9]\+\).*/\1/p"
}
__sp_jdk_short_version() {
    if [ $(__sp_jdk_major_version) -gt 8 ]; then
	echo $__sp_version | tr '+' '_'
    else
	echo $__sp_version | tr -d '-'
    fi
}
__sp_export_vars() {
    echo "Add $(__sp_installation_path) to PATH"
    __SP_JDK_ORIGINAL_PATH="${PATH}"
    __SP_JDK_ORIGINAL_JAVA_HOME="${JAVA_HOME}"

    export PATH="$(__sp_installation_path):${PATH}"
    export JAVA_HOME=$(__sp_installation_path)
}
__sp_restore_exported_vars() {
    if [ -v __SP_JDK_ORIGINAL_PATH ]; then
	export PATH="${__SP_JDK_ORIGINAL_PATH}"
	unset __SP_JDK_ORIGINAL_PATH
    fi
    if [ -v __SP_JDK_ORIGINAL_JAVA_HOME ]; then
      export JAVA_HOME="${__SP_JDK_ORIGINAL_JAVA_HOME}"
      unset __SP_JDK_ORIGINAL_JAVA_HOME
    fi
}
__sp_installation_path() {
    if [ $(__sp_jdk_major_version) -gt 8 ]; then
	echo $__sp_installation_base_dir/jdk-$__sp_version
    else
	echo $__sp_installation_base_dir/jdk$__sp_version
    fi

    #     case "$(uname -s)" in
    # 	CYGWIN*|MINGW*|MSYS*)
    # 	    echo $__sp_installation_base_dir/node-$__sp_version-win-x64
    # 	    ;;
    # 	*)
    # 	    echo $__sp_installation_base_dir/node-$__sp_version-linux-x64/bin
    # 	    ;;
    #     esac
}
__sp_is_installed() {
    java -version 2>/dev/null &&
	(java -version 2>&1 | grep $__sp_version)
}
__sp_installation_file() {
    local major_version=$(__sp_jdk_major_version)
    local short_version=$(__sp_jdk_short_version)

    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    echo OpenJDK${__sp_jdk_major_version}U-jdk_x64_windows_hotspot_$__sp_jdk_short_version.zip
	    ;;
	*)
	    echo OpenJDK${__sp_jdk_major_version}U-jdk_x64_linux_hotspot_$__sp_jdk_short_version.tar.gz
	    ;;
    esac
}
__sp_install_binaries() {
    echo "Install installation binaries"

    local trgt_dir=$(dirname $(__sp_installation_path))

    case "$(uname -s)" in
	CYGWIN*|MINGW*|MSYS*)
	    unzip -oq $(__sp_local_installation_file_path) -d $trgt_dir
	    ;;
	,*)
	    tar Jxf $(__sp_local_installation_file_path) -C $__sp_installation_base_dir
	    ;;
    esac
}

__sp_check_installation_file() {
    echo "Check installation file"

    local local_installation_sha256_file=/tmp/$(__sp_installation_file).sha256

    if [ ! -f $local_installation_sha256_file ]; then
	curl -L $(__sp_download_url).sha256.txt -o $local_installation_sha256_file
    fi

    local pwd=$PWD
    cd /tmp
    sha256sum -c $local_installation_sha256_file
    cd $pwd
}

__sp_install_installation_file() {
    echo "Install installation file"

    __sp_check_installation_file
    __sp_install_binaries
}
__sp_download_url() {
    local remote_installation_dir=jdk$__sp_version

    if [ $(__sp_jdk_major_version) -gt 8 ]; then
	local remote_installation_dir=jdk$__sp_version
    fi

    echo https://github.com/adoptium/temurin$__sp_jdk_major_version-binaries/\
	 releases/download/$remote_installation_dir/$(__sp_installation_file)
}
__sp_print_success_message() {
    java -version
}

__sp_main ${@}
