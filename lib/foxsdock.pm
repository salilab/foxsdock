package foxsdock;
use saliweb::frontend;
use strict;

use FindBin;
use File::Copy;


our @ISA = "saliweb::frontend";


sub _display_content {
  my ($self, $content) = @_;
  print $content;
}

sub _display_web_page {
  my ($self, $content) = @_;
  # Call all prefix and suffix methods before printing anything, in case one
  # of them raises an error
  my $prefix = $self->start_html() . "<div id='container'>" . $self->get_header();
  my $suffix = $self->get_footer() . "</div>\n" . $self->end_html;
  my $navigation = $self->get_navigation_lab();
  print $prefix;
  print $navigation;
  $self->_display_content($content);
  print $suffix;
}

sub get_help_page {
  my ($self, $display_type) = @_;
  my $file;
  if ($display_type eq "about") {
    $self->set_page_title("Method Description");
    $file = "about.txt";
  } elsif ($display_type eq "download") {
    $self->set_page_title("download");
    $file = "download.txt";
  } else {
    return $self->SUPER::get_help_page($display_type);
  }
  return $self->get_text_file($file);
}

sub new {
  return saliweb::frontend::new(@_, "##CONFIG##");
}

sub get_navigation_lab {
  return "<div id=\"navigation_lab\">
      &bull;&nbsp; <a href=\"//modbase.compbio.ucsf.edu/foxsdock//help.cgi?type=about\">About FoXSDock</a>&nbsp;
      &bull;&nbsp; <a href=\"//salilab.org/foxsdock\">Web Server</a>&nbsp;
      &bull;&nbsp; <a href=\"//modbase.compbio.ucsf.edu/foxsdock//help.cgi?type=help\">Help</a>&nbsp;
      &bull;&nbsp; <a href=\"//modbase.compbio.ucsf.edu/foxsdock//help.cgi?type=download\">Download</a>&nbsp;
      &bull;&nbsp; <a href=\"//salilab.org/foxs\">FoXS</a>&nbsp;
      &bull;&nbsp; <a href=\"//salilab.org\">Sali Lab</a>&nbsp;
      &bull;&nbsp; <a href=\"//integrativemodeling.org\">IMP</a>&nbsp;
      &bull;&nbsp; <a href=\"//modbase.compbio.ucsf.edu/foxsdock//help.cgi?type=links\">Links</a>&nbsp;</div>\n";
}

sub get_navigation_links {
  my $self = shift;
  my $q = $self->cgi;
  return [
          $q->a({-href=>$self->index_url}, "FoXSDock Home"),
          $q->a({-href=>$self->queue_url}, "FoXSDock Current queue"),
          $q->a({-href=>$self->help_url}, "FoXSDock Help"),
          $q->a({-href=>$self->contact_url}, "FoXSDock Contact")
         ];
}

sub get_project_menu {
  # no menu
  return "";
}

sub get_header {
    my $self = shift;
    my $htmlroot = $self->htmlroot;
    return "<div id='header1'>
  <table> <tbody> <tr> <td halign='left'>
  <table><tr><td><img src=\"$htmlroot/img/logo.png\" alt=\"FoXS\" align = 'right' height = '80' /></td>
             <td><img src=\"$htmlroot/img/logo3.png\" alt=\"Dock\" align = 'left' height = '80' /></td></tr>
         <tr><td><h3>Macromolecular Docking with SAXS Profile</h3> </td></tr></table>
      </td> <td halign='right'><img src=\"$htmlroot/img/logo2.gif\" alt=\"SAXS profile\" height = '80' /></td></tr>
  </tbody>
  </table></div>\n";
}

sub get_footer {
  my $self = shift;
  my $version = $self->version_link;
  return "<hr size='2' width=\"80%\" />
<table><tr><td halign='left'>If you use FoXSDock (version $version), please cite:</td></tr></table>
<div id='address'> Schneidman-Duhovny D, Hammel M, Sali A. Macromolecular docking restrained by a small angle X-ray scattering profile.
J Struct Biol. 2010 [<a href=\"http://dx.doi.org/10.1016/j.jsb.2010.09.023\"> Abstract </a>] <br />
Schneidman-Duhovny D, Hammel M, Tainer JA, and Sali A. FoXS, FoXSDock and MultiFoXS: Single-state and multi-state structural modeling of proteins and their complexes based on SAXS profiles. NAR 2016 [ <a href = \"//doi.org/10.1093/nar/gkw389\"> FREE Full Text </a> ] <br />
    <p> </p>Contact: <script type=\"text/javascript\">escramble(\"dina\",\"salilab.org\")</script><br /></div>\n";
}

sub get_input_form {
  my $self = shift;
  my $q = $self->cgi;

  return
    $q->start_form({-name=>"foxsdockform", -method=>"post", -action=>$self->submit_url}) .

      $q->start_table({ -cellpadding=>5, -cellspacing=>0}) .
        $q->Tr($q->td('Type PDB codes of receptor and ligand molecules or upload files in PDB format  ' .
                      $q->a({-href => $self->help_url . "#sampleinput"}, 'sample input files'))) . $q->end_table .

      $q->start_table({ -border=>0, -cellpadding=>5, -cellspacing=>0, -width=>'99%'}) .
        $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url}, $q->b('Receptor'))]) ,
           $q->td({ -align=>'left'}, [$q->textfield({-name=>'receptor', -maxlength => 10, -size => 10}) .
                  ' (PDB:chainId e.g. 2kai:AB)']),
           $q->td({ -align=>'left'}, [$q->b('or') . ' upload file: ' . $q->filefield({-name=>'recfile', -size => 10})])) .


        $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url}, $q->b('Ligand'))]) ,
           $q->td({ -align=>'left'}, [$q->textfield({-name=>'ligand', -maxlength => 10, -size => 10}) .
                  ' (PDB:chainId e.g. 2kai:I)']),
           $q->td({ -align=>'left'}, [$q->b('or') . ' upload file: ' . $q->filefield({-name=>'ligfile', -size => 10})])) .

        $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url}, $q->b('Complex SAXS profile'))]),
           $q->td({ -align=>'left'}, [$q->filefield({-name=>'saxsfile', -size => 10})])) .

        $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url}, $q->b('e-mail address'))]),
           $q->td({ -align=>'left'}, [$q->textfield({-name => 'email'})]),
           $q->td({ -align=>'left'}, ['(the results are sent to this address, optional)'])) .


        $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url}, $q->b('Complex type'))]),
           $q->td({ -align=>'left'}, ['<select name="moltype"> <option>Enzyme-inhibitor</option> <option>Antibody-antigen</option> <option selected="selected">Default</option></select>']),
           $q->td({ -align=>'left'}, ['Please specify receptor and ligand in the corresponding order!'])) .

        $q->Tr($q->td({ -align=>'left', -colspan => 2}, [$q->submit(-value => 'Submit') . $q->reset(-value => 'Clear')])) .

        $q->Tr($q->td({ -align=>'left', -colspan => 3}, [$q->b('Advanced Parameters')])) .

        $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url}, $q->b('Weighted SAXS score'))]),
               $q->td({ -align=>'left'}, ['<input type="checkbox" name="weighted"></input>']),
               $q->td({ -align=>'left'}, ['Weighted SAXS scoring that accounts for monomers contribution'])) .

        $q->Tr($q->td({ -align=>'left'}, [$q->a({-href => $self->help_url . "#dist"}, $q->b('Distance constraints'))]),
               $q->td({ -align=>'left'}, [$q->filefield({-name=>'distfile', -size => 10})])) .

        $q->Tr($q->td({ -align=>'left', -colspan => 2}, [$q->submit(-value => 'Submit') . $q->reset(-value => 'Clear')])) .

    $q->end_table . $q->end_form;


#<tr><td><b>Advanced Parameters </b></td></tr>\n
#<tr><td align=left>Receptor Binding Site:</td>
#<td colspan=2 align=left><input type=file name=recsitefile size=10></td></tr>\n
#<tr><td align=left>Ligand Binding Site:</td>
#<td colspan=2 align=left><input type=file name=ligsitefile size=10></td></tr>\n
#<tr><td COLSPAN=2>
#<INPUT TYPE=\"submit\" NAME=\"Submit\" VALUE=\"Submit Form\">
#<input TYPE=\"reset\" NAME=\"Clear\" VALUE=\"Clear\">
#</td></tr></table>";

#<tr><td align=left WIDTH=20%><b>Clustering RMSD:</b></td>
#<td align=left WIDTH=20%><input type=text name=rmsd value=4.0></td></tr>\n

}

sub get_index_page {
  my $self = shift;
  my $q = $self->cgi;

  my $input_form = get_input_form($self, $q);

  return "$input_form\n";
}

sub get_submit_page {
  my $self = shift;
  my $q = $self->cgi;
  print $q->header();
  my $receptor = lc $q->param('receptor');
  my $ligand = lc $q->param('ligand');
  my $profile = $q->param('saxsfile');
  my $email = $q->param('email');

  #my $rmsd = $q->param('rmsd');
  my $moltype = $q->param('moltype');
  my $weighted_score = $q->param('weighted');

  #check input validity:
  #if(($rmsd !~ /^\d[\.]\d+$/ and $rmsd !~ /^\d$/) or $rmsd <= 0.0 or $rmsd >= 10.0) {
  #  throw saliweb::frontend::InputValidationError("Invalid rmsd value $rmsd. Rmsd must be > 0 and < 10.0\n");
  #}

  if($moltype eq "Enzyme-inhibitor") { $moltype = "EI"; }
  else {
    if($moltype eq "Antibody-antigen") { $moltype = "AA"; }
    else {
      if($moltype eq "Default") { $moltype = "Default"; }
      else {
        throw saliweb::frontend::InputValidationError("Error in the types of molecules<p>");
      }
    }
  }

  check_optional_email($email);

  #create job directory time_stamp
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
  my $time_stamp = $sec."_".$min."_".$hour."_".$mday."_".$mon."_".$year;
  my $job = $self->make_job($time_stamp, $self->email);
  my $jobdir = $job->directory;

  my $recFileUsed = 0;
  my $ligFileUsed = 0;

  #receptor molecule
  my $receptorFileName = "";
  #pdb code
  if(length $receptor > 0) {
    $receptorFileName = get_pdb_chains($receptor, $jobdir);
    $receptorFileName =~ s/.*[\/\\](.*)/$1/;
  } else {
    # or file upload
    my $recfile = $q->param("recfile");
    if(length $recfile > 0 and length $receptor==0) {
      $recFileUsed = 1;
      $recfile =~ s/.*[\/\\](.*)/$1/;
      $recfile = removeSpecialChars($recfile);
      $recfile =~ s/^docking\.res\.([\d]+)\.pdb$/dockingres$1\.pdb/; #in case someone calls it docking.res.X.pdb (reserved for output files)
      my $rupload_filehandle = $q->upload("recfile");
      open UPLOADFILE, ">$jobdir/$recfile";
      while ( <$rupload_filehandle> ) { print UPLOADFILE; }
      close UPLOADFILE;
      my $filesize = -s "$jobdir/$recfile";
      if($filesize == 0) {
        throw saliweb::frontend::InputValidationError("You have uploaded an empty file: $recfile");
      }
      $receptorFileName = $recfile;
    } else {
      throw saliweb::frontend::InputValidationError("Error in receptor molecule input: please specify PDB code or upload file");
    }
  }

  #ligand molecule
  my $ligandFileName = "";
  #pdb code
  if(length $ligand > 0) {
    $ligandFileName = get_pdb_chains($ligand, $jobdir);
    $ligandFileName =~ s/.*[\/\\](.*)/$1/;
  } else {
    # or file upload
    my $ligfile = $q->param("ligfile");
    if(length $ligfile > 0 and length $ligand==0) {
      $ligFileUsed = 1;
      $ligfile =~ s/.*[\/\\](.*)/$1/;
      $ligfile = removeSpecialChars($ligfile);
      $ligfile =~ s/^docking\.res\.([\d]+)\.pdb$/dockingres$1\.pdb/; # reserved for output files
      my $lupload_filehandle = $q->upload("ligfile");
      open UPLOADFILE, ">$jobdir/$ligfile";
      while ( <$lupload_filehandle> ) { print UPLOADFILE; }
      close UPLOADFILE;
      my $filesize = -s "$jobdir/$ligfile";
      if($filesize == 0) {
        throw saliweb::frontend::InputValidationError("You have uploaded an empty file: $ligfile");
      }
      $ligandFileName = $ligfile;
    } else {
      throw saliweb::frontend::InputValidationError("Error in ligand molecule input: please specify PDB code or upload file");
    }
  }

  #saxs file
  my $profileFileName = "-";
  if(length $profile > 0) {
    $profile =~ s/.*[\/\\](.*)/$1/;
    $profile = removeSpecialChars($profile);
    my $upload_filehandle = $q->upload("saxsfile");
    open UPLOADFILE, ">$jobdir/$profile";
    while ( <$upload_filehandle> ) { print UPLOADFILE; }
    close UPLOADFILE;
    my $filesize = -s "$jobdir/$profile";
    if($filesize == 0) {
      throw saliweb::frontend::InputValidationError("You have uploaded an empty profile file: $profile");
    }
    $profileFileName = $profile;
  }
  #convert if needed
  `tr '\r' '\n' < $profileFileName > $profileFileName.tmp`;
  rename("$profileFileName.tmp", $profileFileName);
  `dos2unix $profileFileName`;


  # Advanced parameters
  # receptor binding site
  my $recsitefile = $q->param("recsitefile");
  if(length $recsitefile > 0) {
    $recsitefile =~ s/.*[\/\\](.*)/$1/;
    $recsitefile = removeSpecialChars($recsitefile);
    my $rupload_filehandle = $q->upload("recsitefile");
    open UPLOADFILE, ">$jobdir/$recsitefile";
    while ( <$rupload_filehandle> ) { print UPLOADFILE; }
    close UPLOADFILE;
    my $filesize = -s "$jobdir/$recsitefile";
    if($filesize == 0) {
      throw saliweb::frontend::InputValidationError("You have uploaded an empty file: $recsitefile");
    }
  } else {
    $recsitefile = '-';
  }
  # ligand binding site
  my $ligsitefile = $q->param("ligsitefile");
  if(length $ligsitefile > 0) {
    $ligsitefile =~ s/.*[\/\\](.*)/$1/;
    $ligsitefile = removeSpecialChars($ligsitefile);
    my $rupload_filehandle = $q->upload("ligsitefile");
    open UPLOADFILE, ">$jobdir/$ligsitefile";
    while ( <$rupload_filehandle> ) { print UPLOADFILE; }
    close UPLOADFILE;
    my $filesize = -s "$jobdir/$ligsitefile";
    if($filesize == 0) {
      throw saliweb::frontend::InputValidationError("You have uploaded an empty file: $ligsitefile");
    }
  } else {
    $ligsitefile = '-';
  }

  # distance constraints file
  my $distfile = $q->param("distfile");
  if(length $distfile > 0) {
    $distfile =~ s/.*[\/\\](.*)/$1/;
    $distfile = removeSpecialChars($distfile);
    my $rupload_filehandle = $q->upload("distfile");
    open UPLOADFILE, ">$jobdir/$distfile";
    while ( <$rupload_filehandle> ) { print UPLOADFILE; }
    close UPLOADFILE;
    my $filesize = -s "$jobdir/$distfile";
    if($filesize == 0) {
      throw saliweb::frontend::InputValidationError("You have uploaded an empty file: $distfile");
    }
    `cp $jobdir/$distfile $jobdir/distance_constraints.txt`;
  } else {
    $distfile = '-';
  }

  my $input_line = $jobdir . "/input.txt";
  open(INFILE, "> $input_line")
    or throw saliweb::frontend::InternalError("Cannot open $input_line: $!");
  print INFILE "$receptorFileName $ligandFileName --saxs $profileFileName --complex_type $moltype";
  if($weighted_score) { print INFILE " --weighted_saxs_score"; }
  print INFILE "\n";
  close(INFILE);

  my $data_file_name = $jobdir . "/data.txt";
  open(DATAFILE, "> $data_file_name")
    or throw saliweb::frontend::InternalError("Cannot open $data_file_name: $!");
  print DATAFILE "$receptorFileName $ligandFileName --saxs $profileFileName --complex_type $moltype $email\n";
  close(DATAFILE);

  $job->submit($email);

  #my $line = $job->results_url . $receptorFileName . $ligandFileName . $profileFileName  . $moltype . $email;
  my $line = $job->results_url . " " . $receptorFileName . " " . $ligandFileName . " " . $profileFileName . " " . $moltype . " " . $email;
  `echo $line >> ../submit.log`;

  # Inform the user of the job name and results URL
  return $q->p("Your job has been submitted with job ID " . $job->name) .
    $q->p("Results will be found at <a href=\"" . $job->results_url . "\">this link</a>.") .
    $q->p("You will receive an e-mail with results link once the job has finished");
}

sub get_results_page {
  my ($self, $job) = @_;
  my $q = $self->cgi;

  my $return = '';
  my $jobname = $job->name;
  my $joburl = $job->results_url;
  my $passwd = $q->param('passwd');
  my $from = $q->param('from');
  my $to = $q->param('to');
  if(length $from == 0) { $from = 1; $to = 20; }

  $return .= print_input_data($job);
  if(-f 'results_saxs.txt') {
    $return .= display_output_table($joburl, $from, $to);
    $return .= $q->p("<a href=\"" . $job->get_results_file_url('results_saxs.txt') . "\">Download output file</a>.");
  } else {
    $return .= $q->p("No output file was produced. Please inspect the log files to determine the problem.");
    $return .= $q->p("<a href=\"" . $job->get_results_file_url('foxsdock.log') . "\">View FoXSDock log file</a>.");
    $return .= $q->p("<a href=\"" . $job->get_results_file_url('patch_dock.log') . "\">View PatchDock log file</a>.");
    #$return .= $q->p("<a href=\"" . $job->get_results_file_url('fiberdock.log') . "\">View FiberDock log file</a>.");
  }
  #$return .= $job->get_results_available_time();
  return $return;
}

sub display_output_table {
  #my ($self, $job) = @_;
  my $joburl = shift;
  my $first = shift;
  my $last = shift;
  my $return = "";

  $return .= "<hr size=2 width=90% />";
  $return .= print_table_header();

  open(DATA, "results_saxs.txt");
  my $ligandPdb = "";
  my $receptorPdb = "";
  my $transNum = 0;
  my @colors=("#cccccc","#efefef");
  while(<DATA>) {
    chomp;
    my @tmp=split('\|',$_);
    if($#tmp>0 and $tmp[0] =~/\d/) {
      $transNum++;
      if($transNum >= $first and $transNum <= $last) {
        my $zscore = $tmp[1];
        my $saxs_score = $tmp[4];
        my $energy_score = $tmp[6];

        my @trans = split(' ', $tmp[$#tmp]);
        my $roundedTrans = "";
        foreach my $trans (@trans) {
          $roundedTrans = $roundedTrans . " " . sprintf("%.2f", $trans);
        }

        my $color = $colors[$transNum % 2];
        $return .= "<tr bgcolor=$color><td>$transNum</td>
                                <td>$zscore</td>
                                <td>$saxs_score</td>
                                <td>$energy_score </td>
                                <td align=left> $roundedTrans</td>";
        # generate PDB link
        my $pdb_joburl = $joburl;
        $pdb_joburl =~ s/results/model/;
        my $pdb_url = $pdb_joburl . "&from=$transNum&to=$transNum";
        $return .= "<td> <a href=\"" . $pdb_url . "\"> result$transNum.pdb </a></td>";
        # generate link to model page
        my $model_url = $pdb_url;
        $model_url =~ s/model/model2/;
        $return .= "<td> <a href=\"" . $model_url . "\"> view </a></td>";
        $return .= "</tr>";
      }
    }
  }

  # links to previous and next twenty results
  $return .= "<tr><td>";
 if($first > 20) {
    my $prev_from = $first - 20;
    my $prev_to = $last - 20;
    my $prev_page_url = $joburl . "&from=$prev_from&to=$prev_to";
    $return .= "<a href=\"" . $prev_page_url . "\">&laquo;&laquo; show prev 20 </a>";
  }
  $return .= "</td><td></td><td></td><td></td><td></td><td>";
  if($last < $transNum) {
    my $next_from = $first + 20;
    my $next_to = $last + 20;
    my $next_page_url = $joburl . "&from=$next_from&to=$next_to";
    $return .= "<a href=\"" . $next_page_url . "\">&raquo;&raquo; show next 20 </a>";
  }
  $return .= "</td></tr></table>";
  return $return;
}

sub print_table_header() {
return "
<table cellspacing=\"0\" cellpadding=\"0\" width=\"90%\" align=center>
<tr>
<td><font color=blue><b>Model No</b></td>
<td><font color=blue><b>Z-Score</b></td>
<td><font color=blue><b>SAXS &chi; score</b></td>
<td><font color=blue><b>Energy score</b></td>
<td><font color=blue><b>Transformation</b></td>
<td><font color=blue><b>PDB file of the complex</b></td>
</tr>
";
}

sub print_input_data() {
  my $job = shift;

  my $filename = "input.txt";
  open FILE, "<$filename" or die "Can't open file: $filename";
  my @dataFile = <FILE>;
  my $dataLine = $dataFile[0];
  chomp($dataLine);
  my @data = split(' ',$dataLine);

  my $receptor_url = $job->get_results_file_url($data[0]);
  my $ligand_url = $job->get_results_file_url($data[1]);
  my $profile_url = $job->get_results_file_url($data[3]);

  my $return = "<table width=\"90%\"><tr>
<td><font color=blue>Receptor</td>
<td><font color=blue>Ligand</td>
<td><font color=blue>SAXS Profile</td>
<td><font color=blue>Complex Type</td>
</tr>";

  $return .= "<tr><td><a href=\"". $receptor_url . "\">  $data[0] </a> </td> " .
    " <td><a href=\"". $ligand_url . "\"> $data[1] </a> </td> " .
      " <td><a href=\"". $profile_url . "\">  $data[3] </a> </td> <td> $data[5] </td> </tr></tbody></table>";
  return $return;
}

sub format_user_error {
  my ($self, $exc) = @_;
  my $q = $self->{'CGI'};
  my $msg = $exc->text;
  my $ret = $q->p("&nbsp;") .
    $q->p($q->b("An error occurred during your request:")) .
      "<div class=\"standout\"><p>$msg</p></div>";
  if ($exc->isa('saliweb::frontend::InputValidationError')) {
    $ret .= $q->p($q->b("Please click on your browser's \"BACK\" " .
                        "button, and correct the problem."));
  }
  return $ret;
}

sub removeSpecialChars {
  my $str = shift;
  $str =~ s/[^\w,^\d,^\.]//g;
  return $str;
}

sub trimExtension {
  my $str = shift;
  my $size = length $str;
  #trim ".xxx" extension if exists
  if($size > 4 and substr($str, -4, 1) eq '.') {
    $str = substr $str, 0, $size-4;
  }
  return $str;
}

1;
