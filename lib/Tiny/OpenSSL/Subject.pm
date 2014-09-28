use strict;
use warnings;

package Tiny::OpenSSL::Subject;

# ABSTRACT: X509 Subject object.
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

=method dn

Returns the X509 subject string.
