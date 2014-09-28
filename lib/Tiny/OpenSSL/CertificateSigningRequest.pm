use strict;
use warnings;

package Tiny::OpenSSL::CertificateSigningRequest;

# ABSTRACT: Default Abstract Description, Please Change.
# VERSION

use Moo;
use Types::Standard qw( InstanceOf );
use Path::Tiny;
use Capture::Tiny qw( :all );
use Tiny::OpenSSL::Config qw($CONFIG);

with 'Tiny::OpenSSL::Role::Entity';

has subject => (
    is       => 'rw',
    isa      => InstanceOf ['Tiny::OpenSSL::Subject'],
    required => 1
);

has key =>
    ( is => 'rw', isa => InstanceOf ['Tiny::OpenSSL::Key'], required => 1 );

sub create {
    my $self = shift;

    my @args = @{ $CONFIG->{req}{opts} };

    push @args, '-subj', $self->subject->dn;
    push @args, '-key',  $self->key->file;

    my $pass_file = Path::Tiny->tempfile;
    $pass_file->spew( $self->key->password );

    push( @args, '-passin', sprintf( 'file:%s', $pass_file ) );

    push @args, '-out', $self->file;

    my ( $stdout, $stderr, $exit ) = capture {
        system( $CONFIG->{openssl}, @args );
    };

    if ( $exit != 0 ) {
        croak( sprintf( 'cannot create csr: %s', $stderr ) );
    }

    $self->ascii( $self->file->slurp );

    return 1;
}

1;
