use strict;
use warnings;

package Tiny::OpenSSL::Certificate;

# ABSTRACT: X509 Certificate Object.
# VERSION

use Moo;
use Types::Standard qw( InstanceOf );

with 'Tiny::OpenSSL::Role::Entity';

has [qw(issuer subject)] =>
    ( is => 'rw', isa => InstanceOf ['Tiny::OpenSSL::Subject'] );

has key => ( is => 'rw', isa => InstanceOf ['Tiny::OpenSSL::Key'] );

1;

=method issuer

A Tiny::OpenSSL::Subject object for the issuer of the certificate.

=method subject

A Tiny::OpenSSL::Subject object for the subject of the certificate.

=method key

A Tiny::OpenSSL::Key object.
