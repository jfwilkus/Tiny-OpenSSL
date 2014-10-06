use strict;
use warnings;

package Tiny::OpenSSL::Key;

# ABSTRACT: Key object.
# VERSION

use Carp;
use Moo;
use Types::Standard qw( Str InstanceOf Int );
use Path::Tiny;
use Capture::Tiny qw( :all );
use Tiny::OpenSSL::Config qw($CONFIG);

with 'Tiny::OpenSSL::Role::Entity';

has password => ( is => 'rw', isa => Str );

has bits =>
    ( is => 'rw', isa => Int, default => sub { $CONFIG->{key}{bits} } );

sub create {
    my $self = shift;

    my @args = @{ $CONFIG->{key}{opts} };

    if ( -f $self->file && $self->file->lines > 0 ) {
        $self->load;
        return 1;
    }

    my $pass_file;

    if ( $self->password ) {
        $pass_file = Path::Tiny->tempfile;

        $pass_file->spew( $self->password );
        push( @args, sprintf('-%s', $CONFIG->{key}{block_cipher} ) );
        push( @args, '-passout', sprintf( 'file:%s', $pass_file ) );
    }

    push( @args, '-out', $self->file );
    push( @args, $self->bits );

    my ( $stdout, $stderr, $exit ) = capture {
        system( $CONFIG->{openssl}, @args );
    };

    if ( $exit != 0 ) {
        croak( sprintf( 'cannot create key: %s', $stderr ) );
    }

    $self->ascii( $self->file->slurp );

    return 1;
}

1;

=method password

Password for the key.

=method bits

Number of bits for the key, default is 2048.

=method create

Create key.
