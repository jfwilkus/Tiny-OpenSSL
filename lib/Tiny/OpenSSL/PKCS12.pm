use strict;
use warnings;

package Tiny::OpenSSL::PKCS12;

# ABSTRACT: Tiny::OpenSSL::PKCS12 Object
# VERSION

use Moo;
use Carp;
use Types::Standard qw( Str InstanceOf );
use Capture::Tiny qw( :all );
use Tiny::OpenSSL::Config qw($CONFIG);

with 'Tiny::OpenSSL::Role::Entity';

has certificate => (
    is       => 'rw',
    isa      => InstanceOf ['Tiny::OpenSSL::Certificate'],
    required => 1
);

has key => (
    is       => 'rw',
    isa      => InstanceOf ['Tiny::OpenSSL::Key'],
    required => 1
);

has identity => (
    is       => 'rw',
    isa      => Str,
    required => 1
);

has passphrase => (
    is       => 'rw',
    isa      => Str,
    required => 1
);

=method create

Generates a PKCS12 file

    my $p12 = Tiny::OpenSSL::PKCS12->new(
        certificate => $cert,
        key         => $key,
        passphrase  => $passphrase,
        identity    => $identity
    );

=cut

sub create {
    my $self = shift;

    my $pass_file = Path::Tiny->tempfile;
    $pass_file->spew( $self->passphrase );

    my @args = (
        'pkcs12', '-export',
        '-in',    $self->certificate->file,
        '-inkey', $self->key->file,
        '-name',  $self->identity,
        '-out',   $self->file,
        '-passout', sprintf( 'file:%s', $pass_file )
    );

    my ( $stdout, $stderr, $exit ) = capture {
        system( $CONFIG->{openssl}, @args );
    };

    if ( $exit != 0 ) {
        croak( sprintf( 'cannot create pkcs12 file: %s', $stderr ) );
    }

    return 1;
}

1;
