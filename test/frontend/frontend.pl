#!/usr/bin/perl -w

use saliweb::Test;
use Test::More 'no_plan';

BEGIN {
    use_ok('foxsdock');
}

my $t = new saliweb::Test('foxsdock');

# Test get_navigation_links
{
    my $self = $t->make_frontend();
    my $links = $self->get_navigation_links();
    isa_ok($links, 'ARRAY', 'navigation links');
    like($links->[0], qr#<a href="http://modbase/top/">FoXSDock Home</a>#,
         'Index link');
    like($links->[1],
         qr#<a href="http://modbase/top/queue.cgi">FoXSDock Current queue</a>#,
         'Queue link');
}

# Test get_footer
{
    my $self = $t->make_frontend();
    my $txt = $self->get_footer();
    like($txt, qr#If you use FoXSDock.*<div.*Tainer.*</div>#ms,
         'Footer');
}
