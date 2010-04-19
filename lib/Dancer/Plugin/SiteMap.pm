package Dancer::Plugin::SiteMap;

use strict;
use Dancer qw(:syntax);
use Dancer::Config qw(setting);
use Dancer::Plugin;
use XML::Simple;

=head1 NAME

Dancer::Plugin::SiteMap - Automated site map for the Dancer web framework.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.03';

# add this plugin to Dancer
register_plugin;


# Add the routes for both the XML sitemap and the standalone one.
Dancer::Route->add('get', '/sitemap.xml' => sub {
    _xml_sitemap();
});

Dancer::Route->add('get', '/sitemap' => sub {
    _html_sitemap();
});


=head1 SYNOPSIS

    use Dancer;
    use Dancer::Plugin::SiteMap;

Yup, its that simple.

=head1 DESCRIPTION

Plugin module for the Dancer web framwork that automagically adds sitemap
routes to the webapp. Currently adds /sitemap and /sitemap.xml where the
former is a basic HTML list and the latter is an XML document of URLS.

Currently it only adds staticly defined routes for the GET method.

Using the module is literally that simple... 'use' it and your app will
have a site map.

The HTML site map list can be styled throught the CSS class 'sitemap'

=cut

# The action handler for the automagic /sitemap route. Uses the list of
# URLs from _retreive_get_urls and outputs a basic HTML template to the
# browser using the standard layout if one is defined.
sub _html_sitemap {
    my @urls  = _retreive_get_urls();
    my $content = qq[ <h2> Site Map </h2>\n<ul class="sitemap">\n ];

    for my $url (@urls) {
        $content .= qq[ <li><a href="$url">$url</a></li>\n ];
    }
    $content .= qq[ </ul>\n ];

    my $options ||= {layout => 1};
    my $layout = setting('layout');
    undef $layout unless $options->{layout};

    $layout .= '.tt' if $layout !~ /\.tt/;
    $layout = path(setting('views'), 'layouts', $layout);

    my $full_content =
        Dancer::Template->engine->render($layout, { content => $content });

    return $full_content;
};


# The action handler for the automagic /sitemap.xml route. Uses the list of
# URLs from _retreive_get_urls and outputs an XML document to the browser.
sub _xml_sitemap {
    my @urls = _retreive_get_urls();
    my @sitemap_urls;

    # add the "loc" key to each url so XML::Simple creates <loc></loc> tags.
    for my $url (@urls) {
        push @sitemap_urls, { loc => [ $url ] };
    }

    # create a hash for XML::Simple to turn into XML.
    my %urlset = (
        xmlns => 'http://www.sitemaps.org/schemas/sitemap/0.9',
        url   => \@sitemap_urls
    );

    my $xs  = new XML::Simple( KeepRoot   => 1,
                               ForceArray => 0,
                               KeyAttr    => {urlset => 'xmlns'},
                               XMLDecl    => '<?xml version="1.0" encoding="UTF-8"?>' );
    my $xml = $xs->XMLout( { urlset => \%urlset } );

    content_type "text/xml";
    return $xml;
};



# Obtains the list of URLs from Dancers Route Registry.
sub _retreive_get_urls {
    my $routes     = Dancer::Route::Registry->routes;
    my @get_routes = @{ $routes->{get} };
    my @urls;

    # push all the static routes into an array.
    for my $route (@get_routes) {
        push @urls, $route->{route} if ref($route->{route}) !~ m/HASH/;
    }

    return sort(@urls);
};


=head1 AUTHOR

James Ronan, C<< <james at ronanweb.co.uk> >>


=head1 BUGS

Please report any bugs or feature requests to C<bug-dancer-plugin-sitemap at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dancer-Plugin-SiteMap>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer::Plugin::SiteMap


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dancer-Plugin-SiteMap>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dancer-Plugin-SiteMap>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dancer-Plugin-SiteMap>

=item * Search CPAN

L<http://search.cpan.org/dist/Dancer-Plugin-SiteMap/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright 2010 James Ronan.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Dancer::Plugin::SiteMap
