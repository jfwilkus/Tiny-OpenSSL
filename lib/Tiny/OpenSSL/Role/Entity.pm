use strict;
use warnings;

package Tiny::OpenSSL::Role::Entity;

# ABSTRACT: Provides common tasks for Tiny::OpenSSL objects.
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

=method ascii

The ascii representation of the artifact.

=method file

The Path::Tiny object for the file.

=method write

Write the artifact to the file.  By default, the file is a Path::Tiny->tempfile, override to store permanently.

