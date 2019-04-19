#!/usr/bin/perl -w

use saliweb::Test;
use Test::More 'no_plan';
use Test::Exception;
use File::Temp qw(tempdir);

BEGIN {
    use_ok('foxsdock');
    use_ok('saliweb::frontend');
}

my $t = new saliweb::Test('foxsdock');

# Check results page

sub make_input_txt {
    ok(open(FH, "> input.txt"), "Open input.txt");
    print FH "5_new.pdb ICAM_Btype.pdb --saxs 4.dat --complex_type Default";
    ok(close(FH), "Close input.txt");
}

# Check get_results_page, ok job
{
    my $frontend = $t->make_frontend();
    my $tmpdir = tempdir(CLEANUP=>1);
    ok(chdir($tmpdir), "chdir into tempdir");
    my $job = new saliweb::frontend::CompletedJob($frontend,
                        {name=>'testjob', passwd=>'foo', directory=>$tmpdir,
                         archive_time=>'2009-01-01 08:45:00'});

    $frontend->cgi->param('from', '1');
    $frontend->cgi->param('to', '20');
    make_input_txt();

    ok(open(FH, "> results_saxs.txt"), "Open results_saxs.txt");
    print FH "receptorPdb Str 5_new.pdb
ligandPdb Str ICAM_Btype.pdb
     # |  Score  | filt| ZScore |  SAXS  | Zscore |  SOAP     | Zscore | Transformation
     #      1 |  -3.559 |  +  | -2.503 |  2.147 | -1.055 | -1610.932 | -2.504 |  -1.636 -0.108 0.361 -40.146 -84.326 -72.529
     #           2 |  -3.461 |  +  | -2.434 |  1.812 | -1.292 | -1429.678 | -2.169 |  -1.357 0.112 0.608 -29.160 -68.705 -80.858
";
    ok(close(FH), "Close results_saxs.txt");

    my $ret = $frontend->get_results_page($job);
    like($ret, '/Receptor.*Ligand.*SAXS Profile.*Complex Type.*' .
               'results.cgi\/testjob\/5_new\.pdb\?passwd=foo.*' .
               'Model No.*Z\-Score.*Download output file/ms',
               'display ok job');

    chdir("/");
}

# Check get_results_page, failed job
{
    my $frontend = $t->make_frontend();
    my $tmpdir = tempdir(CLEANUP=>1);
    ok(chdir($tmpdir), "chdir into tempdir");
    my $job = new saliweb::frontend::CompletedJob($frontend,
                        {name=>'testjob', passwd=>'foo', directory=>$tmpdir,
                         archive_time=>'2009-01-01 08:45:00'});

    $frontend->cgi->param('from', '1');
    $frontend->cgi->param('to', '20');
    make_input_txt();

    my $ret = $frontend->get_results_page($job);
    like($ret, '/No output file was produced.*'.
               'results.cgi\/testjob\/foxsdock\.log\?passwd=foo.*' .
               'results.cgi\/testjob\/patch_dock\.log\?passwd=foo.*/ms',
               'display failed job');

    chdir("/");
}
