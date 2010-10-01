package Plack::Session::Store::TokyoTyrant;
use strict;
use warnings;

our $VERSION = '0.01';

use Storable ();
use MIME::Base64 ();

use TokyoTyrant ();

use parent 'Plack::Session::Store';

use Plack::Util::Accessor qw[prefix rdb serializer deserializer];

sub new {
    my ($class, %args) = @_;

    unless (ref $args{server} eq 'ARRAY') {
        die "'server' argument must be an arrayref";
    }

    $args{key_prefix} ||= 'sessions:';

    # stolen from Plack::Session::Store::DBI ;)
    $args{serializer} ||=
        sub { MIME::Base64::encode_base64( Storable::nfreeze($_[0]) ) };
    $args{deserializer} ||=
        sub { Storable::thaw( MIME::Base64::decode_base64($_[0]) ) };

    my $rdb = TokyoTyrant::RDB->new;
    $rdb->open( @{$args{server}} ) or die $rdb->errmsg($rdb->ecode);

    my %params = (
        rdb          => $rdb,
        prefix       => $args{key_prefix},
        serializer   => $args{serializer},
        deserializer => $args{deserializer},
    );

    return bless \%params, $class;
}

sub fetch {
    my ($self, $session_id) = @_;
    my $key = $self->prefix . $session_id;

    my $value = $self->rdb->get($key);
    return defined $value ? $self->deserializer->($value) : undef;
}

sub store {
    my ($self, $session_id, $session) = @_;
    my $key = $self->prefix . $session_id;

    $self->rdb->put($key, $self->serializer->($session))
        or warn $self->rdb->errmsg($self->rdb->ecode);

}

sub remove {
    my ($self, $session_id) = @_;
    my $key = $self->prefix . $session_id;

    $self->rdb->out($key)
        or warn $self->rdb->errmsg($self->rdb->ecode);
}

1;
__END__

=head1 NAME

Plack::Session::Store::TokyoTyrant - TokyoTyrant based session store

=head1 SYNOPSIS

  use Plack::Builder;
  use Plack::Middleware::Session;
  use Plack::Session::Store::TokyoTyrant;

  my $app = sub { ... };

  builder {
    enable 'Session',
        store => Plack::Session::Store::TokyoTyrant->new(
            server => ['localhost', 1987],
            key_prefix => 'myapp:sessions:',
        );
    $app;
  };

=head1 DESCRIPTION

Plack::Session::Store::TokyoTyrant is TokyoTyrant based session store.

This is a subclass of Plack::Session::Store and implements its full interface.

=head1 PARAMETERS

=over 4

=item server

Specify the server to connect (this is required). The value must be an arrayref. See also SYNOPSIS.

=item key_prefix

You can specify the prefix of the key.

By default, the key will be

    sessions:4af3dff5eb71a9f4cae32e6e959f13b5d38aab47

When you specified 'myapp:sessions:' as the key_prefix, the keys will be

    myapp:sessions:0a39db2ac23acfdbac7aa745c579f64431ed0953

=item serializer, deserializer

This part is same as Plack::Session::Store::DBI version 0.10. See L<Plack::Session::Store::DBI>.

=back

=head1 AUTHOR

punytan E<lt>punytan@gmail.comE<gt>

This module was written under the influence of L<Plack::Session::Store::DBI>.

=head1 SEE ALSO

L<TokyoTyrant>, L<TokyoTyrant::RDB>, L<Plack::Session::Store::DBI>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
