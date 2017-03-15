#!/usr/bin/perl -w

use strict;
use FindBin;
my $home = "$FindBin::Bin";

if ($#ARGV !=1) {
  print "extract_scores.pl <score_file> <trans_file>\n";
  print "extract scores for transformations numbers in the trans_file\n";
  exit;
}

my ($solutions_ref, $transCounter, $arraySize) = readDataFile($ARGV[0]);
my @solutions = @$solutions_ref;

open(DATA, $ARGV[1]) or die "Couldn't open results file $ARGV[1]\n";

my @tmp = `grep # $ARGV[0]`; #`head -n5 $ARGV[0]`;
print @tmp;
while(<DATA>) {
  chomp;
  my @tmp=split(' ',$_);
  my $transNum = $tmp[0];
  # access solutions with trans number
  for(my $i=0; $i<=$arraySize; $i++) {
    print "$solutions[$transNum-1][$i]";
    if($i != $arraySize) { print "|"; }
  }
  print "\n";
}

sub readDataFile {
  my $filename = shift;
  open(DATA, $filename) or die "Couldn't open results file $filename\n";

  my @solutions=();
  my $transCounter = 0;
  my $arraySize = 5;
  while(<DATA>) {
    chomp;
    my @tmp=split('\|',$_);
    if($#tmp>0 and $tmp[0] =~/\d/) {
      $arraySize = $#tmp;
      $transCounter++;
      push(@solutions, [@tmp]);
    }
  }
  close DATA;
  #print "$transCounter $arraySize\n";
  return (\@solutions, $transCounter, $arraySize);
}
