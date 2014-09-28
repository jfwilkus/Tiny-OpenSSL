use strict;
use warnings;

package Tiny::OpenSSL::CertificateAuthority;

# ABSTRACT: Certificate Authority object.
# VERSION

use Moo;
use Carp;
use Capture::Tiny qw( :all );
use Tiny::OpenSSL::Config qw($CONFIG);

extends 'Tiny::OpenSSL::Certificate';

sub sign {
    my $self = shift;

    return 1;
}

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


=method sign

Sign a certificate.

    my $ca->sign($csr);

=method self_sign

Self sign certificate.

    my $ca->self_sign($csr);
