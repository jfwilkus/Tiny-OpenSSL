use strict;
use warnings;

package Tiny::OpenSSL::Certificate;

# ABSTRACT: X509 Certificate Object.
# VERSION

use Moo;
use Carp;
use Types::Standard qw( InstanceOf );
use Tiny::OpenSSL::Config qw($CONFIG);
use Capture::Tiny qw( :all );

with 'Tiny::OpenSSL::Role::Entity';

has [qw(issuer subject)] =>
    ( is => 'rw', isa => InstanceOf ['Tiny::OpenSSL::Subject'] );

has key => ( is => 'rw', isa => InstanceOf ['Tiny::OpenSSL::Key'] );

sub self_sign {

    my $self = shift;
    my $csr  = shift;

    if ( !defined $csr ) {
        croak 'csr is not defined';
    }

    my $pass_file = Path::Tiny->tempfile;
    $pass_file->spew( $self->key->password );

    my @args = (
        'x509',     '-req',
        '-days',    $CONFIG->{ca}{days},
        '-in',      $csr->file,
        '-signkey', $self->key->file,
        '-passin', sprintf( 'file:%s', $pass_file ),
        '-out',    $self->file
    );

    my ( $stdout, $stderr, $exit ) = capture {
        system( $CONFIG->{openssl}, @args );
    };

    if ( $exit != 0 ) {
        croak( sprintf( 'cannot sign certificate: %s', $stderr ) );
    }

    $self->issuer( $self->subject );
    $self->ascii( $self->file->slurp );

    return 1;
}

1;

=method issuer

A Tiny::OpenSSL::Subject object for the issuer of the certificate.

=method subject

A Tiny::OpenSSL::Subject object for the subject of the certificate.

=method key

A Tiny::OpenSSL::Key object.

=method self_sign

Self sign certificate.

    $cert->self_sign($csr);
