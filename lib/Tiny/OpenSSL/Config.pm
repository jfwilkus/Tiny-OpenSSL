use strict;
use warnings;

package Tiny::OpenSSL::Config;

# ABSTRACT: Load default Tiny::OpenSSL configuration
# VERSION

use YAML::Tiny;
use File::ShareDir qw(dist_file);

local $YAML::UseCode  = 0 if !defined $YAML::UseCode;
local $YAML::LoadCode = 0 if !defined $YAML::LoadCode;

use base qw(Exporter);

our @EXPORT = qw( $CONFIG );

my $yaml = YAML::Tiny->read(dist_file 'Tiny-OpenSSL', 'config.yml');

our $CONFIG = $yaml->[0];

$CONFIG->{openssl} = 'openssl';

1;
