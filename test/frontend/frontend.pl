#!/usr/bin/perl -w

use saliweb::Test;
use Test::More 'no_plan';
use Test::Exception;
use File::Temp qw(tempdir);

BEGIN {
    use_ok('foxsdock');
}

my $t = new saliweb::Test('foxsdock');

# Test get_navigation_links
{
    my $self = $t->make_frontend();
    my $links = $self->get_navigation_links();
    isa_ok($links, 'ARRAY', 'navigation links');
    like($links->[0], qr#<a href="http://modbase/top/">Web Server</a>#,
         'Index link');
    like($links->[2],
         qr#<a href="http://modbase/top/queue.cgi">Queue</a>#,
         'Queue link');
}

# Test get_help_page
{
    my $self = $t->make_frontend();
    $self->{server_name} = "foxsdock";
    my $txt = $self->get_help_page("download");
    $txt = $self->get_help_page("about");
    $txt = $self->get_help_page("contact");
    # Can't assert that the content is OK, because we're probably in the
    # wrong directory to find it
}

# Test get_project_menu
{
    my $self = $t->make_frontend();
    my $txt = $self->get_project_menu();
    is($txt, "", 'Project menu');
}

# Test get_header
{
    my $self = $t->make_frontend();
    my $txt = $self->get_header();
    like($txt, qr#<div.*Docking with SAXS.*</div>#ms,
         'Header');
}

# Test get_footer
{
    my $self = $t->make_frontend();
    my $txt = $self->get_footer();
    like($txt, qr#If you use FoXSDock.*<div.*Tainer.*</div>#ms,
         'Footer');
}

# Test get_index_page
{
    my $self = $t->make_frontend();
    my $txt = $self->get_index_page();
    like($txt, qr/Weighted SAXS scoring/ms,
         'get_index_page');
}

# Test removeSpecialChars
{
    is(foxsdock::removeSpecialChars("abcd 1234 %!_-. ABCD"), "abcd1234_.ABCD",
       "removeSpecialChars");
}

# Test trimExtension
{
    is(foxsdock::trimExtension("abcd"), "abcd",
       "trimExtension (no extension)");
    is(foxsdock::trimExtension("1234.txt"), "1234",
       "trimExtension (3-letter extension)");
    is(foxsdock::trimExtension("5678.a"), "5678.a",
       "trimExtension (1-letter extension)");
}

# Test get_profile_filename
{
    my $tmpdir = tempdir(CLEANUP=>1);
    ok(chdir($tmpdir), "chdir into tempdir");

    dies_ok { foxsdock::get_profile_filename() }
            "get_profile_filename, no input.txt";

    ok(open(FH, ">input.txt"));
    print FH "test.pdb ICAM.pdb --saxs 6.dat --complex_type Default";
    ok(close(FH));

    is(foxsdock::get_profile_filename(), "6.dat", "get_profile_filename, ok");

    chdir("/");
}


