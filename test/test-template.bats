#!/usr/bin/env bats
setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
}

@test "Default version must be printed" {
    run load ../src/setup-template.sh

    assert_line -p 'Default: tmpl_default-version'
}
@test "Environment must be clean after execution with default version" {
    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    run load ../src/setup-template.sh

    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
}
@test "No previous installation default version" {
    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]

    run load ../src/setup-template.sh -v some_other-version

    assert [ $OPTIND -eq 1 ]
    assert [ -z $INSTALLATION_BASE_DIR ]
    assert [ -z $VERSION ]
}
