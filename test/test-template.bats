#!/usr/bin/env bats
setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  SPT_ORIGINAL_PATH="$PATH"
}
teardown() {
    PATH="$SPT_ORIGINAL_PATH"
}

@test "Must print success message" {
    run . src/setup-template.sh

    assert_line 'TMPL successfully installed'
}
@test "Environment must be clean after execution with default version" {
    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    . src/setup-template.sh

    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
    assert [ $PATH == "$HOME/opt/tmpl-tmpl_default-version:$SPT_ORIGINAL_PATH" ]
}
@test "Environment must be clean after execution with given version" {
    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    . src/setup-template.sh -v some_other-version

    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
    assert [ $PATH == "$HOME/opt/tmpl-some_other-version:$SPT_ORIGINAL_PATH" ]
}
