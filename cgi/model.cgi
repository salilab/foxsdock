#!/usr/bin/perl -w
BEGIN { @INC = ("../lib/",@INC); }
use foxsdock;
my $m = new foxsdock;
$m->generate_model_pdb();
