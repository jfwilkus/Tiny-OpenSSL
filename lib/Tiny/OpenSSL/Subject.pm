use strict;
use warnings;

package Tiny::OpenSSL::Subject;

# ABSTRACT: Default Abstract Description, Please Change.
# VERSION

use Moo;
use Types::Standard qw( Str InstanceOf Int );
use Tiny::OpenSSL::Config qw($CONFIG);

has [ keys %{ $CONFIG->{san} } ] => ( is => 'rw', isa => Str );

sub dn {
    my $self = shift;

    my @subject;

    my @methods =
        qw( country state locality organization organizational_unit commonname );

    for my $method (@methods) {

        if ( $self->$method ) {
            push @subject,
                sprintf( '%s=%s', $CONFIG->{san}{$method}, $self->$method );
        }
    }

    return sprintf( '/%s', join( '/', @subject ) );
}

1;
