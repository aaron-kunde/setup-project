#! /bin/sh

set -e

SPT_ORIGINAL_PATH="$PATH"
INSTALLATION_FILE=/tmp/installation.file

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
    assert "-z $DEFAULT_TMPL_VERSION" \
	   "DEFAULT_TMPL_VERSION is set: $DEFAULT_TMPL_VERSION"
    assert "-z $TMPL_VERSION" \
	   "TMPL_VERSION is set: $TMPL_VERSION"
}

assert_clean_env() {
    assert_no_tmp_global_vars_set
    assert "-z $SETUP_TMPL_ORIGINAL_PATH" \
	   "SETUP_TMPL_ORIGINAL_PATH is set: $SETUP_TMPL_ORIGINAL_PATH"
    assert "! -e $INSTALLATION_FILE" \
	   "Installation file exists"
}


should_successfully_use_default_version_if_no_version_given() {
    assert_clean_env
    
    . ./setup-template.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	"SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-default_version:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"
	
    reset_path_vars
    rm "$INSTALLATION_FILE"
}

should_successfully_use_given_version() {
    assert_clean_env
    
    . ./setup-template.sh -v0
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-0:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"
    
    reset_path_vars
    rm "$INSTALLATION_FILE"
}

should_skip_installation_and_set_paths_if_already_installed() {
    assert_clean_env
    
    . ./setup-template.sh -vinstalled
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-installed:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "! -e $INSTALLATION_FILE" \
	   "Installation file should not exist"
    
    reset_path_vars
    reset_global_vars
}

should_skip_download_and_install_if_installation_file_exists_local() {
    assert_clean_env
    touch "$INSTALLATION_FILE"

    . ./setup-template.sh -v0

    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-0:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"
    
    reset_path_vars
    rm "$INSTALLATION_FILE"
}

should_abort_installation_if_download_fails() {
    assert_clean_env

    . ./setup-template.sh -vdownload_fail

    assert_no_tmp_global_vars_set
    assert "-z $SETUP_TMPL_ORIGINAL_PATH" \
	   "SETUP_TMPL_ORIGINAL_PATH is set: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "! -e $INSTALLATION_FILE" \
	   "Installation file should not exist"
    
    reset_path_vars
}

should_abort_installation_if_installation_fails() {
    assert_clean_env

    . ./setup-template.sh -vinstallation_fail

    assert_no_tmp_global_vars_set
    assert "-z $SETUP_TMPL_ORIGINAL_PATH" \
	   "SETUP_TMPL_ORIGINAL_PATH is set: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"

    reset_path_vars
    rm "$INSTALLATION_FILE"
}

should_successfully_use_default_version_as_new_version_if_no_version_given_and_installed_before() {
    assert_clean_env
    
    . ./setup-template.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-default_version:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"
	
    . ./setup-template.sh -v0
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-0:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"
    
    reset_path_vars
    reset_global_vars
    rm "$INSTALLATION_FILE"
}

should_successfully_use_given_version_as_new_version_if_installed_before() {
    assert_clean_env
    
    . ./setup-template.sh -v0
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-0:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"
    
    . ./setup-template.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-default_version:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"
	
    reset_path_vars
    rm "$INSTALLATION_FILE"
}

should_abort_installation_and_deinstall_old_version_if_download_fails_and_installed_before() {
    assert_clean_env
    
    . ./setup-template.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-default_version:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"

    rm "$INSTALLATION_FILE"
    . ./setup-template.sh -vdownload_fail

    assert_no_tmp_global_vars_set
    assert "-z $SETUP_TMPL_ORIGINAL_PATH" \
	   "SETUP_TMPL_ORIGINAL_PATH is set: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "! -e $INSTALLATION_FILE" \
	   "Installation file should not exist"

    reset_path_vars
}

should_abort_installation_and_deinstall_old_version_if_installation_fails_and_installed_before() {
    assert_clean_env
    
    . ./setup-template.sh
    
    assert_no_tmp_global_vars_set
    assert "${SETUP_TMPL_ORIGINAL_PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "SETUP_TMPL_ORIGINAL_PATH != SPT_ORIGINAL_PATH: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = $HOME/opt/tmpl-default_version:${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"

    rm "$INSTALLATION_FILE"
    . ./setup-template.sh -vinstallation_fail

    assert_no_tmp_global_vars_set
    assert "-z $SETUP_TMPL_ORIGINAL_PATH" \
	   "SETUP_TMPL_ORIGINAL_PATH is set: $SETUP_TMPL_ORIGINAL_PATH"
    assert "${PATH// /§} = ${SPT_ORIGINAL_PATH// /§}" \
	   "PATH is not correct: $PATH"
    assert "-e $INSTALLATION_FILE" \
	   "Installation file should exist"
	
    reset_path_vars
    rm "$INSTALLATION_FILE"
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
