#!/bin/bash -ex
#===============================================================================
#
#    DESCRIPTION: CI Job Execution Script for Perl modules
#
#          USAGE: job.sh
#
#       REVISION: 1.0.4
#
#===============================================================================
#
# CHANGELOG
# 1.0.4 2015-06-25 James F Wilkus, <jfwilkus@cpan.org>
#
#  - Backout last change
#
# 1.0.3 2015-06-25 James F Wilkus, <jfwilkus@cpan.org>
#
#  - Remove wild card after dist name
#
# 1.0.2 2015-06-25 James F Wilkus, <jfwilkus@cpan.org>
#
#  - Run dzil clean before smoking dist
#
# 1.0.1 2015-06-25 James F Wilkus, <jfwilkus@cpan.org>
#
#  - Get distname from dist.ini
#
# 1.0.0 2015-06-24 James F Wilkus, <jfwilkus@cpan.org>
#
#  - Initial release
#
#===============================================================================

# Make sure that perlbrew install for job is uninstalled
function cleanup {
  perlbrew uninstall "${PERL_VERSION}-${BUILD_ID}"
}

trap cleanup EXIT

export RELEASE_TESTING=1
export AUTOMATED_TESTING=1
export AUTHOR_TESTING=1
export HARNESS_OPTIONS=j10:c
export HARNESS_TIMER=1

source "${PERLBREW_ROOT}/etc/bashrc"

# Set BUILD_ID to Unix Epoch time by default. Solaris date command does not
# support %s so we have to use perl time command for portability.
BUILD_ID=${BUILD_ID:-$(perl -e 'print time . "\n"')}

PERL_VERSION=${PERL_VERSION:-"perl-5.22.0"}

CPAN_MIRROR=${CPAN_MIRROR:-"http://www.cpan.org"}
CPANM_OPTIONS=${CPANM_OPTIONS:-"-n --quiet --mirror-only --mirror $CPAN_MIRROR"}

perlbrew -j 5 -n -q install "${PERL_VERSION}" --as "${PERL_VERSION}-${BUILD_ID}"

perlbrew use "${PERL_VERSION}-${BUILD_ID}"

cpanm ${CPANM_OPTIONS} Dist::Zilla

dzil authordeps --missing | cpanm ${CPANM_OPTIONS}
dzil listdeps --missing | cpanm ${CPANM_OPTIONS}

dzil clean

# Smoke test the distribution
dzil smoke --author --release

# Build the module for test coverage and module metrics
dzil build

# Report Unit test coverage
dzil cover

# Gather module metrics
countperl "$(awk '/^name/ { print $3 }' dist.ini )"-*
