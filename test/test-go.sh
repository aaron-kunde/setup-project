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
    assert "-z $DEFAULT_GO_VERSION" \
	   "DEFAULT_GO_VERSION is set: $DEFAULT_GO_VERSION"
    assert "-z $GO_VERSION" \
	   "GO_VERSION is set: $GO_VERSION"
}

assert_clean_env() {
    assert_no_tmp_global_vars_set
    assert "-z $SETUP_NODEJS_ORIGINAL_PATH" \
	   "SETUP_NODEJS_ORIGINAL_PATH is set: $SETUP_NODEJS_ORIGINAL_PATH"
    assert "! -e /tmp/go1.19.4.windows-amd64.zip" \
 	   "Installation file exists: /tmp/go1.19.4.windows-amd64.zip"
    assert "! -e /tmp/go1.18.9.windows-amd64.zip" \
 	   "Installation file exists: /tmp/go1.18.9.windows-amd64.zip"
}

should_successfully_use_default_version_if_no_version_given() {
    assert_clean_env
    
    . $(dirname ${0})/../src/setup-go.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.19.4/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.19.4.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.19.4" \
 	   "Installation dir should exist: $HOME/opt/go1.19.4"
	
    reset_path_vars
    rm /tmp/go1.19.4.windows-amd64.zip
    rm -rf $HOME/opt/go1.19.4
}

should_successfully_use_given_version() {
    assert_clean_env
    
    . $(dirname ${0})/../src/setup-go.sh -v1.18.9
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.18.9/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.18.9.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.18.9" \
 	   "Installation dir should exist: $HOME/opt/go1.18.9"
    
    reset_path_vars
    rm /tmp/go1.18.9.windows-amd64.zip
}

should_skip_installation_and_set_paths_if_already_installed() {
    assert_clean_env
    
    . $(dirname ${0})/../src/setup-go.sh -v1.18.9
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.18.9/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "! -e /tmp/go1.18.9.windows-amd64.zip" \
	   "Installation file should not exist"
    assert "-e $HOME/opt/go1.18.9" \
 	   "Installation dir should exist: $HOME/opt/go1.18.9"
    
    reset_path_vars
    rm -rf $HOME/opt/go1.18.9
}

should_skip_download_and_install_if_installation_file_exists_local() {
    assert_clean_env

    . $(dirname ${0})/../src/setup-go.sh -v1.18.9

    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.18.9/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.18.9.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.18.9" \
 	   "Installation dir should exist: $HOME/opt/go1.18.9"
    
    reset_path_vars
    rm /tmp/go1.18.9.windows-amd64.zip
    rm -rf $HOME/opt/go1.18.9
}

should_abort_installation_if_download_fails() {
    assert_clean_env

    . $(dirname ${0})/../src/setup-go.sh -vdownload_fail || echo "-> Expected failure"

    assert_clean_env
}

should_abort_installation_if_installation_fails() {
    assert_clean_env
    touch /tmp/go1.19.4.windows-amd64.zip

    . $(dirname ${0})/../src/setup-go.sh || echo "-> Expected failure"

    assert_no_tmp_global_vars_set
    assert "-z $SETUP_GO_ORIGINAL_PATH" \
	   "SETUP_GO_ORIGINAL_PATH is set: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.19.4.windows-amd64.zip" \
	   "Installation file should exist"

    rm /tmp/go1.19.4.windows-amd64.zip
}

should_successfully_use_default_version_as_new_version_if_no_version_given_and_installed_before() {
    assert_clean_env
    
    . $(dirname ${0})/../src/setup-go.sh -v1.18.9
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.18.9/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.18.9.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.18.9" \
 	   "Installation dir should exist: $HOME/opt/go1.18.9"
    
    . $(dirname ${0})/../src/setup-go.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.19.4/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.19.4.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.19.4/bin" \
 	   "Installation dir should exist: $HOME/opt/go1.19.4/bin"
	
    reset_path_vars
    rm /tmp/go1.19.4.windows-amd64.zip
    rm -rf $HOME/opt/go1.19.4
    rm /tmp/go1.18.9.windows-amd64.zip
    rm -rf $HOME/opt/go1.18.9
}

should_successfully_use_given_version_as_new_version_if_installed_before() {
    assert_clean_env
    
    . $(dirname ${0})/../src/setup-go.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.19.4/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.19.4.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.19.4" \
 	   "Installation dir should exist: $HOME/opt/go1.19.4"
	
    . $(dirname ${0})/../src/setup-go.sh -v1.18.9
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.18.9/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.18.9.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.18.9" \
 	   "Installation dir should exist: $HOME/opt/go1.18.9"
    
    reset_path_vars
    rm /tmp/go1.19.4.windows-amd64.zip
    rm -rf $HOME/opt/go1.19.4
    rm /tmp/go1.18.9.windows-amd64.zip
    rm -rf $HOME/opt/go1.18.9
}

should_abort_installation_and_deinstall_old_version_if_download_fails_and_installed_before() {
    assert_clean_env
    
    . $(dirname ${0})/../src/setup-go.sh -v1.18.9
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.18.9/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.18.9.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.18.9" \
 	   "Installation dir should exist: $HOME/opt/go1.18.9"

    . $(dirname ${0})/../src/setup-go.sh -vdownload_fail || echo "-> Expected failure"

    rm /tmp/go1.18.9.windows-amd64.zip
    assert_clean_env
    rm -rf $HOME/opt/go1.18.9
}

should_abort_installation_and_deinstall_old_version_if_installation_fails_and_installed_before() {
    assert_clean_env
    
    . $(dirname ${0})/../src/setup-go.sh -v1.18.9
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_GO_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_GO_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/go1.18.9/bin:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.18.9.windows-amd64.zip" \
	   "Installation file should exist"
    assert "-e $HOME/opt/go1.18.9" \
 	   "Installation dir should exist: $HOME/opt/go1.18.9"

    touch /tmp/go1.19.4.windows-amd64.zip

    . $(dirname ${0})/../src/setup-go.sh || echo "-> Expected failure"

    assert_no_tmp_global_vars_set
    assert "-z $SETUP_GO_ORIGINAL_PATH" \
	   "SETUP_GO_ORIGINAL_PATH is set: $SETUP_GO_ORIGINAL_PATH"
    assert "${PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e /tmp/go1.19.4.windows-amd64.zip" \
	   "Installation file should exist"
	
    rm /tmp/go1.19.4.windows-amd64.zip
    rm /tmp/go1.18.9.windows-amd64.zip
    rm -rf $HOME/opt/go1.18.9
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
