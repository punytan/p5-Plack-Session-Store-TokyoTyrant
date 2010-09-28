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

    $args{key_prefix} ||= 'sessions';
    $args{separator}  ||= ':';

    # stolen from Plack::Session::Store::DBI ;)
    $args{serializer} ||=
        sub { MIME::Base64::encode_base64( Storable::nfreeze($_[0]) ) };
    $args{deserializer} ||=
        sub { Storable::thaw( MIME::Base64::decode_base64($_[0]) ) };

    my $rdb = TokyoTyrant::RDB->new;
    $rdb->open( @{$args{server}} ) or die $rdb->errmsg($rdb->ecode);

    my %params = (
        rdb          => $rdb,
        prefix       => $args{key_prefix} . $args{separator},
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

Plack::Session::Store::TokyoTyrant -

=head1 SYNOPSIS

  use Plack::Session::Store::TokyoTyrant;

=head1 DESCRIPTION

Plack::Session::Store::TokyoTyrant is

=head1 AUTHOR

punytan E<lt>punytan@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
