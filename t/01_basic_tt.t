use strict;
use warnings;

use Test::More;
use Test::Requires qw(TokyoTyrant);

use Plack::Session::Store::TokyoTyrant;
use Plack::Session::State::Cookie;

use t::lib::TestSession;

my $rdb;

eval {
    $rdb = TokyoTyrant::RDB->new;
    $rdb->open("localhost", 1978) or die $rdb->errmsg($rdb->ecode);
};

SKIP: {
    skip "TokyoTyrant is not running on localhost:1978", 1 if $@;

    t::lib::TestSession::run_all_tests(
        store  => Plack::Session::Store::TokyoTyrant->new(
            server => ['localhost', 1978],
            key_prefix => 'plack_session_store_tokyotyrant_tests',
        ),
        state  => Plack::Session::State->new,
        env_cb => sub {
            open my $in, '<', \do { my $d };
            my $env = {
                'psgi.version'    => [ 1, 0 ],
                'psgi.input'      => $in,
                'psgi.errors'     => *STDERR,
                'psgi.url_scheme' => 'http',
                SERVER_PORT       => 80,
                REQUEST_METHOD    => 'GET',
                QUERY_STRING      => join "&" => map { $_ . "=" . $_[0]->{ $_ } } keys %{$_[0] || +{}},
            };
        },
    );

    $rdb->iterinit;
    while (defined(my $key = $rdb->iternext)) {
        $rdb->out($key) if $key =~ /^plack_session_store_tokyotyrant_tests/;
    }
}

done_testing;
