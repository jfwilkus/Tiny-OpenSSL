use strict;
use warnings;

package Tiny::OpenSSL::Key;

# ABSTRACT: Wrapper for OpenSSL Key tasks
# VERSION

use Carp;
use Moo;
use Types::Standard qw( Str InstanceOf Int );
use Path::Tiny;
use Capture::Tiny qw( :all );
use Tiny::OpenSSL::Config qw($CONFIG);

has password => ( is => 'rw', isa => Str );
has bits =>
    ( is => 'rw', isa => Int, default => sub { $CONFIG->{key}{bits} } );
has ascii => ( is => 'rw', isa => Str );
has file => ( is => 'rw', isa => InstanceOf ['Path::Tiny'] );

sub create {
    my $self = shift;

    my @args = @{ $CONFIG->{key}{opts} };

    my $pass_file;

    if ( $self->password ) {
        $pass_file = Path::Tiny->tempfile;

        $pass_file->spew( $self->password );

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

sub write {
    my $self = shift;

    if ( $self->file ) {
        $self->file->spew( $self->ascii );
        return 1;
    }

    return;
}

1;
