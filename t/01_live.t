use strict;
use XML::Atom::Lifeblog;

use Test::More;

unless ($ENV{LIFEBLOG_API}) {
    Test::More->import(skip_all => "LIFEBLOG_API not set");
    exit;
}

# XXX This is not testing, but for debugging :)
plan 'no_plan';

my($uri, $user, $pass) = split /\|/, $ENV{LIFEBLOG_API};

my $client = XML::Atom::Lifeblog->new();
$client->username($user);
$client->password($pass);

use LWP::Simple qw(mirror);
my $tmp = "t/me.jpg";
mirror "http://blog.bulknews.net/me.jpg" => $tmp;

my $entry = $client->postLifeblog($uri, "Hello", "This is me", $tmp);
ok $entry->link->href, $entry->link->href;

$tmp = "t/jedi.3gp";
mirror "http://joi.ito.com/images/jedi.3gp" => $tmp;

$entry = $client->postLifeblog($uri, "Hello", "From Joi", $tmp) or warn $client->errstr;
ok $entry->link->href, $entry->link->href;

END { unlink $_ for qw(t/me.jpg t/jedi.3gp) };



