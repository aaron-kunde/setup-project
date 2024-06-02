#!/usr/bin/env bats
SPT_SCRIPT=src/setup-template.sh

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-file/load'

  SPT_ORIGINAL_PATH="$PATH"
}
teardown() {
    PATH="$SPT_ORIGINAL_PATH"
}

@test "Must print versions to install with default version" {
    run . $SPT_SCRIPT

    assert_line 'Install version: tmpl_default-version'

    rm /tmp/installation.file
}
@test "Must print versions to install with given version" {
    run . $SPT_SCRIPT -v some_other-version

    assert_line 'Install version: some_other-version'

    rm /tmp/installation.file
}
@test "Environment must be clean after execution if succeeds with default version" {
    . $SPT_SCRIPT

    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    rm /tmp/installation.file
}

@test "Exported variables must be set if succeeds with default version" {
    . $SPT_SCRIPT

    assert [ $PATH == "$HOME/opt/tmpl-tmpl_default-version:$SPT_ORIGINAL_PATH" ]

    rm /tmp/installation.file
}
@test "Exported variables must be set if succeeds with given version" {
    . $SPT_SCRIPT -v some_other-version

    assert [ $PATH == "$HOME/opt/tmpl-some_other-version:$SPT_ORIGINAL_PATH" ]

    rm /tmp/installation.file
}

@test "Must print success message" {
    run . $SPT_SCRIPT

    assert_line 'TMPL successfully installed'

    rm /tmp/installation.file
}
@test "Must print error message if remote installation file not found" {
    run . $SPT_SCRIPT -v download_fail

    assert_line "ERROR: No remote installation file found. Abort"
    assert_file_not_exists  /tmp/installation.file
}
@test "Environment must be clean after execution if installation fails" {
    . $SPT_SCRIPT -v installation_fail

    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    rm /tmp/installation.file
}
@test "Exported variables must not be set if installation fails" {
    . $SPT_SCRIPT -v installation_fail

    assert [ $PATH == $SPT_ORIGINAL_PATH ]

    rm /tmp/installation.file
}
@test "Should not set variables if version is already installed" {
    PATH="/some/new/path:$SPT_ORIGINAL_PATH"

    . $SPT_SCRIPT -v installed

    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
    assert [ $PATH == "/some/new/path:$SPT_ORIGINAL_PATH" ]
    assert_file_not_exists  /tmp/installation.file
}
@test "Should only output success message if version is already installed" {
    run . $SPT_SCRIPT -v installed

    refute_line "Adding $HOME/opt/tmpl-tmpl_default-version to PATH"
    refute_line "Install version: tmpl_default-version"
    assert_line "TMPL successfully installed"

    assert_file_not_exists  /tmp/installation.file
}
@test "Should try download if local installation file not exists" {
    run . $SPT_SCRIPT

    assert_line "Local installation file not found: /tmp/installation.file. Try, download new one"
    assert_line "Download installation file"

    rm /tmp/installation.file
}
@test "Should not try download if local installation file exists" {
    touch /tmp/installation.file

    run . $SPT_SCRIPT

    refute_line "Local installation file not found: /tmp/installation.file. Try, download new one"

    rm /tmp/installation.file
}
@test "Should try download if remote installation file found" {
    run . $SPT_SCRIPT

    assert_line "Download installation file"

    rm /tmp/installation.file
 }
