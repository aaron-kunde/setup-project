#!/bin/sh
set -e

# Define common assertions
assert_optind_is_1() {
    test $OPTIND -eq 1 ||
	(echo "Fail: OPTIND = 1"; exit 1)
}
assert_no_global_vars_set() {
    test -z $INSTALLATION_BASE_DIR ||
	(echo "Fail: INSTALLATION_BASE_DIR is set: $INSTALLATION_BASE_DIR"; exit 1)
    test -z $VERSION ||
	(echo "Fail: VERSION is set: $VERSION"; exit 1)
}

# Define test cases
environment_must_be_clean_after_execution() {
    assert_optind_is_1
    assert_no_global_vars_set

    . $(dirname ${0})/../src/setup-template.sh

    assert_optind_is_1
    assert_no_global_vars_set
}
default_version_must_be_printed() {
    . $(dirname ${0})/../src/setup-template.sh | grep -qe 'Default: tmpl_default-version'
}

# Execute test cases
environment_must_be_clean_after_execution
default_version_must_be_printed
