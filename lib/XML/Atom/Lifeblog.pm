package XML::Atom::Lifeblog;

use strict;
use vars qw($VERSION);
$VERSION = '0.02';

use Encode;
use File::Basename;
use MIME::Types;
use XML::Atom::Client;
use XML::Atom::Entry;
use base qw(XML::Atom::Client);

sub postLifeblog {
    my($self, $post_uri, $title, $body, $media) = @_;
    my($content, $media_title);
    if (ref($media)) {
	return $self->error("post scalarref is now depreciated.");
    }

    # XXX should it support chunked POST?
    local $/;
    open my $fh, $media or return $self->error("$media: $!");
    $content = <$fh>;
    $media_title = File::Basename::basename($media);

    my $mime_type  = $self->_guess_mime_type($media);
    my $atom_media = $self->_create_media($media_title, $content, $mime_type);
    my $posted = $self->_post_entry($post_uri, $atom_media)
	or return $self->error("POST ($media) failed: " . $self->errstr);
    my $atom_body = $self->_create_body($title, $body, $posted->id, $mime_type);
    return $self->_post_entry($post_uri, $atom_body);
}

sub _guess_mime_type {
    my($self, $media) = @_;
    # MIME::Types doesn't support 3gpp
    if ($media =~ /\.3gpp?$/) {
	# XXX what about audio/3gpp?
	return "video/3gpp";
    } else {
	my $mime = MIME::Types->new->mimeTypeOf($media);
	return $mime ? $mime->type : "application/octet-stream";
    }
}

sub _create_media {
    my($self, $media_title, $content, $mime_type) = @_;

    my $entry = XML::Atom::Entry->new();
    $entry->title($media_title);
    $entry->content($content);
    $entry->content->type($mime_type);

    # add <standalone>1</standalone>
    my $tp = XML::Atom::Namespace->new(standalone => "http://sixapart.com/atom/typepad#");
    $entry->set($tp => "standalone" => 1);
    return $entry;
}

sub _create_body {
    my($self, $title, $body, $id, $mime_type) = @_;
    my $entry = XML::Atom::Entry->new();
    $entry->title($title);
    $entry->content($body);

    # add link rel="related" for the uploaded image
    my $link = XML::Atom::Link->new();
    $link->type($mime_type);
    $link->rel('related');
    $link->href($id);
    $entry->add_link($link);
    return $entry;
}

# XXX XML::Atom::Client's createEntry doesn't return response body
sub _post_entry {
    my $client = shift;
    my($uri, $entry) = @_;
    return $client->error("Must pass a PostURI before posting")
	unless $uri;

    my $req = HTTP::Request->new(POST => $uri);
    $req->content_type('application/x.atom+xml');

    my $xml = $entry->as_xml;
    Encode::_utf8_off($xml);
    $req->content_length(length $xml);
    $req->content($xml);

    my $res = $client->make_request($req);
    return $client->error("Error on POST $uri: " . $res->status_line)
	unless $res->code == 201;
    return XML::Atom::Entry->new(Stream => \$res->content);
}

1;
__END__

=head1 NAME

XML::Atom::Lifeblog - Post lifeblog items using AtomAPI

=head1 SYNOPSIS

  use XML::Atom::Lifeblog;

  my $client = XML::Atom::Lifeblog->new();
  $client->username("Melody");
  $client->password("Nelson");

  my $entry = $client->postLifeblog($PostURI, $title, $body, "foobar.jpg");

=head1 DESCRIPTION

XML::Atom::Lifeblog is a wrapper for XML::Atom::Client that handles
Nokia Lifeblog API to post images associated with text messages.

=head1 METHODS

XML::Atom::Lifeblog is a subclass of XML::Atom::Client.

=head1 postLifeblog

  my $entry = $client->postLifeblog($PostURI, $title, $body, $media);

Creates a new Lifeblog entry and post it to a Lifeblog aware server
using C<< <standalone> >> element. C<$image> is a filepath of image or video files to be posted.

Returns XML::Atom::Entry object for the posted entry.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<XML::Atom::Client>
http://cognections.typepad.com/lifeblog/2004/12/lifeblog_postin.html

=cut
