use inc::Module::Install;
name 'Plack-Session-Store-TokyoTyrant';
all_from 'lib/Plack/Session/Store/TokyoTyrant.pm';

requires 'Storable';
requires 'MIME::Base64';
requires 'Plack::Session::Store';
requires 'TokyoTyrant';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
