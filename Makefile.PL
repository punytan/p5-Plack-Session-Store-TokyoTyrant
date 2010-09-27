use inc::Module::Install;
name 'Plack-Session-Store-TokyoTyrant';
all_from 'lib/Plack/Session/Store/TokyoTyrant.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
