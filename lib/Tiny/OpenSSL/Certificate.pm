use strict;
use warnings;

package Tiny::OpenSSL::Certificate;

# ABSTRACT: Default Abstract Description, Please Change.
# VERSION

use Moo;
use Types::Standard qw( InstanceOf );

with 'Tiny::OpenSSL::Role::Entity';

has [qw(issuer subject)] =>
    ( is => 'rw', isa => InstanceOf ['Tiny::OpenSSL::Subject'] );

has key => ( is => 'rw', isa => InstanceOf ['Tiny::OpenSSL::Key'] );

1;
