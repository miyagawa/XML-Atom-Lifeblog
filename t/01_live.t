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

use LWP::Simple;
my $image = get "http://blog.bulknews.net/me.jpg";

my $client = XML::Atom::Lifeblog->new();
$client->username($user);
$client->password($pass);

my $entry = $client->postLifeblog($uri, "Hello", "This is me", \$image);

ok $entry->link->href, $entry->link->href;


