use strict;
use warnings;

package Tiny::OpenSSL::Role::Entity;

# ABSTRACT: Default Abstract Description, Please Change.
# VERSION

use Moo::Role;
use Types::Standard qw( Str InstanceOf );
use Path::Tiny;

has ascii => ( is => 'rw', isa => Str );

has file => (
    is      => 'rw',
    isa     => InstanceOf ['Path::Tiny'],
    default => sub { return Path::Tiny->tempfile; }
);

sub write {
    my $self = shift;

    if ( $self->file ) {
        $self->file->spew( $self->ascii );
    }

    return 1;
}

1;
