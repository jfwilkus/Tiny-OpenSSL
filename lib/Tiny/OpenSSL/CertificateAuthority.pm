use strict;
use warnings;

package Tiny::OpenSSL::CertificateAuthority;

# ABSTRACT: Certificate Authority object.
# VERSION

use Moo;
use Carp qw(croak);
use Capture::Tiny qw( :all );
use Tiny::OpenSSL::Config qw($CONFIG);

extends 'Tiny::OpenSSL::Certificate';

sub sign {

    my $self = shift;
    my $csr  = shift;
    my $crt  = shift;

    if ( !defined $csr ) {
        croak '$csr is not defined';
    }

    if ( !defined $crt ) {
        croak '$crt is not defined';
    }

    my @args = (
        'ca',              '-policy',
        'policy_anything', '-batch',
        '-cert',           $crt->file,
        '-keyfile',        $self->key->file,
        '-in',             $csr->file,
    );

    my $pass_file;

    if ( $self->key->password ) {

        $pass_file = Path::Tiny->tempfile;
        $pass_file->spew( $self->key->password );

        push( @args, '-passin', sprintf( 'file:%s', $pass_file ) );

    }

    my ( $stdout, $stderr, $exit ) = capture {
        system( $CONFIG->{openssl}, @args );
    };

    if ( $exit != 0 ) {
        croak( sprintf( 'cannot sign certificate: %s', $stderr ) );
    }

    $crt->issuer( $self->subject );
    $crt->ascii( $crt->file->slurp );

    return 1;
}

1;

=method sign

Sign a certificate.

    my $ca->sign($csr);
