use strict;
use warnings;

package Tiny::OpenSSL::CertificateAuthority;

# ABSTRACT: Certificate Authority object.
# VERSION

use Moo;
use Capture::Tiny qw( :all );
use Tiny::OpenSSL::Config qw($CONFIG);

extends 'Tiny::OpenSSL::Certificate';

sub sign {
    my $self = shift;

    return 1;
}

1;


=method sign

Sign a certificate.

    my $ca->sign($csr);

