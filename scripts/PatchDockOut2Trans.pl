#!/usr/bin/perl -w

use strict;

if ($#ARGV != 0) {
  print "PatchDockOut2Trans.pl <PatchDock output file>\n";
  exit;
}

my $CandFileName = $ARGV[0];
open(DATA, $CandFileName);
while(<DATA>) {
  chomp;
  my @tmp=split('\|',$_);
  if($#tmp>0 and $tmp[0] =~/\d/) {
    my $transNum=int $tmp[0];
    print "$transNum $tmp[$#tmp]\n";
  }
}

close (DATA);
