use Test::More;
use Try::Tiny;
use Path::Tiny;

use_ok('Tiny::OpenSSL::Key');

my $key = Tiny::OpenSSL::Key->new;

isa_ok( $key, 'Tiny::OpenSSL::Key' );

can_ok( $key, 'password' );
can_ok( $key, 'file' );

$key->password('asdasdasd');

my $key_ascii = <<KEY;
-----BEGIN RSA PRIVATE KEY-----
MIIBPAIBAAJBAN4x+JTjALZVhSfdsgSoZR5TpuTuwPL6fjq//D4iYBo4sIEbbyCi
juf/h66hS7cyy5y2tt3qqoi2x2+UA6YaxsECAwEAAQJBAMWfKlm54NtLCuhfPML5
xx4HBsxdMc2qT3UPZlkZF+KY2pg7H5zeGoYHdOp3Aptzyx5Jq6ECMTT49uY2wAIV
acECIQD3BMXK0EpynyhZx91o3bufcDPShWCK7yj8vUmz9Fx+6QIhAOZGJN2xtayL
hMLPOHFUa24zlCysWMQmmEscVr+LNhIZAiEAgCqFxdmVByv1b7/37XU+6Fb7THvP
v8afaaN9HlXnuCECIDiWWi7kodmB+6EH3T30WeYd5LbJr5KcTWZ/002Ev0fZAiEA
iX/4mXMThdBBQ8I5zKUOPgDvbOPLV+4LYCfP4Aji1Eo=
-----END RSA PRIVATE KEY-----
KEY

is( $key->bits, 2048, 'key bits set to 2048 default' );

ok( $key->ascii($key_ascii) );
ok( $key->file( Path::Tiny->tempfile ) );
ok( $key->write, 'write key file' );

my $key2 = Tiny::OpenSSL::Key->new( password => 'asdasdasd', bits => 1024 );

ok( $key2->create );

is( $key2->ascii, $key2->file->slurp );

done_testing;
