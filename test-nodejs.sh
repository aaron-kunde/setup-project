#! /bin/sh

set -e

SPT_ORIGINAL_PATH="$PATH"

assert() {
    local assertion=${1}
    local msg=${2}

    # Must not be quoted!
    test $assertion || (
	echo "Assertion fail: $msg"
	exit  1
    )
}

it() {
    echo -e "\nTEST: ${1}\n"

    ${1}

    if [ $? ]; then
	echo -e "\n-> SUCCESS\n"
	return 0
    else
	echo -e "\n-> FAIL\n"
	return 1
    fi
}

assert_no_tmp_global_vars_set() {
    assert "$OPTIND -eq 1" \
	   "OPTIND != 1: $OPTIND"
    assert "-z $INSTALLATION_BASE_DIR" \
	   "INSTALLATION_BASE_DIR is set: $INSTALLATION_BASE_DIR"
    assert "-z $DEFAULT_NODEJS_VERSION" \
	   "DEFAULT_NODEJS_VERSION is set: $DEFAULT_NODEJS_VERSION"
    assert "-z $NODEJS_VERSION" \
	   "NODEJS_VERSION is set: $NODEJS_VERSION"
}

assert_clean_env() {
    assert_no_tmp_global_vars_set
    assert "-z $SETUP_NODEJS_ORIGINAL_PATH" \
	   "SETUP_NODEJS_ORIGINAL_PATH is set: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "! -e /tmp/node-v14.15.4-win-x64.zip" \
 	   "Installation file exists: /tmp/node-v14.15.4-win-x64.zip"
    assert "! -e /tmp/node-v18.12.1-win-x64.zip" \
 	   "Installation file exists: /tmp/node-v18.12.1-win-x64.zip"
}


should_successfully_use_default_version_if_no_version_given() {
    assert_clean_env
    
    . ./setup-nodejs.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	"SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v14.15.4-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v14.15.4-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v14.15.4-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v14.15.4-win-x64"
	
    reset_path_vars
    rm /tmp/node-v14.15.4-win-x64.zip
    rm -rf $HOME/opt/node-v14.15.4-win-x64
}

should_successfully_use_given_version() {
    assert_clean_env
    
    . ./setup-nodejs.sh -vv18.12.1
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v18.12.1-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v18.12.1-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v18.12.1-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v18.12.1-win-x64"
    
    reset_path_vars
    rm /tmp/node-v18.12.1-win-x64.zip
}

should_skip_installation_and_set_paths_if_already_installed() {
    assert_clean_env
    
    . ./setup-nodejs.sh -vv18.12.1
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v18.12.1-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "! -e /tmp/node-v18.12.1-win-x64.zip" \
	   "Installation file should not exist"
    assert "-e $HOME/opt/node-v18.12.1-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v18.12.1-win-x64"
    
    reset_path_vars
    rm -rf $HOME/opt/node-v18.12.1-win-x64
}

should_skip_download_and_install_if_installation_file_exists_local() {
    assert_clean_env

    . ./setup-nodejs.sh -vv18.12.1

    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v18.12.1-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v18.12.1-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v18.12.1-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v18.12.1-win-x64"
    
    reset_path_vars
    rm /tmp/node-v18.12.1-win-x64.zip
    rm -rf $HOME/opt/node-v18.12.1-win-x64
}

should_abort_installation_if_download_fails() {
    assert_clean_env

    . ./setup-nodejs.sh -vdownload_fail || echo "-> Expected failure"

    assert_clean_env
}

should_abort_installation_if_installation_fails() {
    assert_clean_env
    touch /tmp/node-v14.15.4-win-x64.zip

    . ./setup-nodejs.sh || echo "-> Expected failure"

    assert_no_tmp_global_vars_set
    assert "-z $SETUP_NODEJS_ORIGINAL_PATH" \
	   "SETUP_NODEJS_ORIGINAL_PATH is set: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v14.15.4-win-x64.zip" \
	   "Installation file should exist"

    rm /tmp/node-v14.15.4-win-x64.zip
}

should_successfully_use_default_version_as_new_version_if_no_version_given_and_installed_before() {
    assert_clean_env
    
    . ./setup-nodejs.sh -vv18.12.1
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v18.12.1-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v18.12.1-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v18.12.1-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v18.12.1-win-x64"
    
    . ./setup-nodejs.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v14.15.4-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v14.15.4-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v14.15.4-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v14.15.4-win-x64"
	
    reset_path_vars
    rm /tmp/node-v14.15.4-win-x64.zip
    rm -rf $HOME/opt/node-v14.15.4-win-x64
    rm /tmp/node-v18.12.1-win-x64.zip
    rm -rf $HOME/opt/node-v18.12.1-win-x64
}

should_successfully_use_given_version_as_new_version_if_installed_before() {
    assert_clean_env
    
    . ./setup-nodejs.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v14.15.4-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v14.15.4-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v14.15.4-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v14.15.4-win-x64"
	
    . ./setup-nodejs.sh -vv18.12.1
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v18.12.1-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v18.12.1-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v18.12.1-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v18.12.1-win-x64"
    
    reset_path_vars
    rm /tmp/node-v14.15.4-win-x64.zip
    rm -rf $HOME/opt/node-v14.15.4-win-x64
    rm /tmp/node-v18.12.1-win-x64.zip
    rm -rf $HOME/opt/node-v18.12.1-win-x64
}

should_abort_installation_and_deinstall_old_version_if_download_fails_and_installed_before() {
    assert_clean_env
    
    . ./setup-nodejs.sh -vv18.12.1
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v18.12.1-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v18.12.1-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v18.12.1-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v18.12.1-win-x64"

    . ./setup-nodejs.sh -vdownload_fail || echo "-> Expected failure"

    rm /tmp/node-v18.12.1-win-x64.zip
    assert_clean_env
    rm -rf $HOME/opt/node-v18.12.1-win-x64
}

should_abort_installation_and_deinstall_old_version_if_installation_fails_and_installed_before() {
    assert_clean_env
    
    . ./setup-nodejs.sh -vv18.12.1
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_NODEJS_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_NODEJS_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/node-v18.12.1-win-x64:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v18.12.1-win-x64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/node-v18.12.1-win-x64" \
 	   "Installation dir should exist: $HOME/opt/node-v18.12.1-win-x64"

    touch /tmp/node-v14.15.4-win-x64.zip

    . ./setup-nodejs.sh || echo "-> Expected failure"

    assert_no_tmp_global_vars_set
    assert "-z $SETUP_NODEJS_ORIGINAL_PATH" \
	   "SETUP_NODEJS_ORIGINAL_PATH is set: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "${PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/node-v14.15.4-win-x64.zip" \
	   "Installation file should exist"
	
    rm /tmp/node-v14.15.4-win-x64.zip
    rm /tmp/node-v18.12.1-win-x64.zip
    rm -rf $HOME/opt/node-v18.12.1-win-x64
}


echo "Without installation before"
it should_successfully_use_default_version_if_no_version_given
it should_successfully_use_given_version
it should_skip_installation_and_set_paths_if_already_installed
it should_skip_download_and_install_if_installation_file_exists_local
it should_abort_installation_if_download_fails
it should_abort_installation_if_installation_fails

echo "With installation before"
it should_successfully_use_default_version_as_new_version_if_no_version_given_and_installed_before
it should_successfully_use_given_version_as_new_version_if_installed_before
it should_abort_installation_and_deinstall_old_version_if_download_fails_and_installed_before
it should_abort_installation_and_deinstall_old_version_if_installation_fails_and_installed_before
