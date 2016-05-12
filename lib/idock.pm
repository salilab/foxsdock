package idock;
use base qw(saliweb::frontend);
use FindBin;
use File::Copy;
use strict;

sub _display_content {
  my ($self, $content) = @_;
  print $content;
}


sub get_start_html_parameters {
  my ($self, $style) = @_;
  my %param;# = $self->SUPER::get_start_html_parameters($style);
  push @{$param{-script}}, {-language => 'JavaScript',
                            -src => 'html/jquery-1.8.0.js' };
#  push @{$param{-script}}, {-language => 'JavaScript',
#                            -src => 'html/bootstrap.js' };
#  push @{$param{-script}}, {-language => 'JavaScript',
#                            -src => 'html/jquery.validate.js' };
#  push @{$param{-script}}, {-language => 'JavaScript',
#                            -src => 'html/jquery.validate.unobtrusive.js' };
#  push @{$param{-script}}, {-language => 'JavaScript',
#                            -src => 'html/jquery.unobtrusive-ajax.js' };
#  push @{$param{-script}}, {-language => 'JavaScript',
#                            -src => 'http://salilab.org/js/salilab.js'};
  push @{$param{-style}->{'-src'}}, 'html/metro-bootstrap.css';
  push @{$param{-style}->{'-src'}}, 'html/font-awesome.css';
  $param{-title} = "idock: integrative docking approach";
  return %param;
}

sub _display_web_page {
  my ($self, $content) = @_;
  # Call all prefix and suffix methods before printing anything, in case one
  # of them raises an error

  #my $prefix = $self->start_html() . $self->get_header();
  #my $suffix = $self->get_footer() . $self->end_html;
  #my $navigation = $self->get_navigation_lab();
  #print $prefix;
  #print $navigation;
  #print "<div class='container'>";
  #$self->_display_content($content);
  #print "</div>\n";
  #print $suffix;


  print $self->start_html();
  print $self->get_navigation_lab();
  print "<div class='container'>";
  print $self->get_header();
  $self->_display_content($content);
  print $self->get_footer();
  print "</div>\n";
  print $self->end_html;
}

sub get_help_page {
  my ($self, $display_type) = @_;
  my $file;
  if ($display_type eq "contact") {
    $file = "contact.txt";
  } elsif ($display_type eq "news") {
    $file = "news.txt";
  } elsif ($display_type eq "about") {
    $file = "about.txt";
  } elsif ($display_type eq "FAQ") {
    $file = "FAQ.txt";
  } elsif ($display_type eq "links") {
    $file = "links.txt";
  } elsif ($display_type eq "download") {
    $file = "download.txt";
  } else {
    $file = "help.txt";
  }
  return $self->get_text_file($file);
}

sub new {
  return saliweb::frontend::new(@_, @CONFIG@);
}

sub get_navigation_lab {
  return "
    <header class='navbar navbar-inverse navbar-fixed-top bs-docs-nav' role='banner'>
      <div class='container'>
        <div class='navbar-header'>
          <button class='navbar-toggle' data-target='.bs-navbar-collapse' data-toggle='collapse' type='button'>
           <span class='sr-only'>Toggle navigation</span>
           <span class='icon-bar'></span>
           <span class='icon-bar'></span>
           <span class='icon-bar'></span>
         </button>
         <a class='navbar-brand' href='http://modbase.compbio.ucsf.edu/idock/help.cgi?type=about\'>About IDock</a>
       </div>
   <nav class='collapse navbar-collapse bs-navbar-collapse' role='navigation'>
   <ul class=\"nav navbar-nav\">
   <li> <a href=\"http://salilab.org/idock\">Web Server</a>
   <li> <a href=\"http://modbase.compbio.ucsf.edu/idock/help.cgi?type=help\">Help</a>
   <li> <a href=\"http://modbase.compbio.ucsf.edu/idock/help.cgi?type=FAQ\">FAQ</a>
   <li> <a href=\"http://modbase.compbio.ucsf.edu/idock/help.cgi?type=download\">Download</a>
   <li> <a href=\"http://salilab.org/foxs\">FoXS</a>
   <li> <a href=\"http://salilab.org\">Sali Lab</a>
   <li> <a href=\"http://salilab.org/imp\">IMP</a>
   <li class='dropdown'>
      <a class='dropdown-toggle' data-toggle='dropdown' href=\"idock links\"> Links <span class='caret'></span> </a>
    <ul class='dropdown-menu'>
       <li><a href='http://bioinfo3d.cs.tau.ac.il/PatchDock/'> PatchDock - docking server </a>
       <li><a href='http://bioinfo3d.cs.tau.ac.il/FireDock/'> FireDock - refinement server </a>      
    </ul>
  </li>


</ul></nav>
</div></header>\n";
}

sub get_navigation_links {
  my $self = shift;
  my $q = $self->cgi;
  return [
          $q->a({-href=>$self->index_url}, "IDock Home"),
          $q->a({-href=>$self->queue_url}, "IDock Current queue"),
          $q->a({-href=>$self->help_url}, "IDock Help"),
          $q->a({-href=>$self->contact_url}, "IDock Contact")
         ];
}

sub get_project_menu {
  # no menu
  return "";
}

sub get_header {
  return "
<div id='content' class='page-header'>
<div class='container'>
<h1>IDock</h1>
<p><h3>Integrative structure determination of protein-protein complexes</p></h3>
</div>
          </div>\n";
}

sub get_footer {
  return "<hr>
<footer class=\"footer\"> <p> <h5> 
  Please cite: Schneidman-Duhovny D. et al. A method for integrative structure determination of protein-protein complexes.
Bioinformatics 2012. [<a href=\"http://bioinformatics.oxfordjournals.org/cgi/content/abstract/bts628?ijkey=Sy9nUO0AGbqDtYJ&keytype=ref\">Abstract</a>] [<a href=\"http://bioinformatics.oxfordjournals.org/cgi/reprint/bts628?ijkey=Sy9nUO0AGbqDtYJ&keytype=ref\">PDF</a>] </h5> 
<p>
  Contact: <script>escramble(\"dina\",\"salilab.org\")</script>
</footer>\n";
}




sub get_input_form {
  my $self = shift;
  my $q = $self->cgi;

 return get_saxs_options();

my $x=   $q->start_form({-name=>"idockform", -method=>"post", -action=>$self->submit_url, -class=>"form-inline", -role=>"form"}) .

  "<div class=\"row\">
     <div class='col-md-2'> Molecule 1 </div>
     <div class='col-md-5'> <div class='input-group'> 
       <span class='input-group-addon'> PDBcode:chains </span>
       <input type=text name=receptor placeholder='2kai:AB'>
     </div> </div>
     <div class='col-md-5'><div class='input-group'>
       <span class='input-group-addon'> or upload file </span>
       <input type=file name=recfile size=10>
     </div></div>
   </div>

   <div class='row'>
     <div class='col-md-2'> Molecule 2 </div>
     <div class='col-md-5'> <div class='input-group'>
       <span class='input-group-addon'> PDBcode:chains </span>
       <input type=text name=ligand placeholder='2kai:I'>
     </div> </div>
     <div class='col-md-5'><div class='input-group'>
       <span class='input-group-addon'> or upload file </span>
       <input type=file name=ligfile size=10>
     </div></div>
   </div>"
.

  "<div class='row'> 
     <div class='col-md-2'> Email address </div>
     <div class='col-md-5 col-md-offset1'> <input type=email name=email placeholder='Email'> </div>
  </div>"

.



#<tr><td align=left><font color=blue><b>Complex SAXS profile:</b></td><td align=left><input type=file name=saxsfile size=10></td></tr>\n

#<tr><td align=left><b>Complex Type:</b></td>
#<td align=left><SELECT name=moltype> <OPTION>Enzyme-inhibitor <OPTION>Antibody-antigen <OPTION SELECTED>Default </SELECT></td>
#<td WIDTH=40% COLSPAN=2> <font color=red> Be sure to give receptor and ligand in the corresponding order! </td></tr>\n

#<tr><td COLSPAN=2>

  "<div class='btn-group'>
     <input type='submit' class='btn btn-default' name='Submit' value='Dock'>
     <input type='reset' class='btn btn-default' name='Clear' value='Clear'>
  </div> "

.


#"<br><div class='row'>
#<input type='button' class='thumbnail tile tile-double' onclick=\"hello\" value='tile'></div>"
#.
get_saxs_options()

. $q->end_form();




#"</form>";


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


sub get_saxs_options {
  #my $saxs_form = "<div class='slidingDiv' style='display: none'>
  #  <div class='row'>
  #   <div class='col-md-2'> Complex SAXS profile </div>
  #   <div class='col-md-5'><div class='input-group'>
  #     <input type=file name=saxsfile size=10>
  #   </div></div>
  #   </div></div>";

  #my $button = "<div class='show_hide'><div class='row'><input type='button' class='btn btn-default' name='saxs' value='SAXS'> </div></div>";

my $html = "<button id='show_hide'>Show</button>

<div id='slidingDiv' style='display: block;'>Check out</div>\n";

my $code = "<script>  $( \"#clickme\" ).click(function() {
  $( \"#book\" ).slideDown( 'slow', function() {

  });
                        }); </script>\n";

  #my $code = "<script> $('.saxsbutton').click(function() { $('.saxsform').toggle('slow'); });</script>\n";


  return $html . $code;


#  my $code = "<table><tr><td><a onclick=\"toggle_visibility_tbody('optional', 'optionaltoggle'); return false;\" id='optionaltoggle' href='#'>
#              <h4>SAXS Options</h4></a></td></tr>
#              <tbody id='optional' style='display:none'> $saxs_form </tbody></table>";

  #my $code = "<div class=\"dropdown_container\">\n" .
  #  "<a onclick=\"\$('saxsopt').slideToggle('fast')\" " .
  #    "href=\"#\">SAXS options</a>\n" .
  #      "<div class=\"dropdown\" id=\"saxsopt\" style=\"display:none\">\n" .
  #         $saxs_form . "\n</div></div>\n";

  #return $code;
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

  check_required_email($email);

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
    $receptorFileName = get_pdb_chains($self, $receptor, $jobdir);
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
    $ligandFileName = get_pdb_chains($self, $ligand, $jobdir);
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

  my $input_line = $jobdir . "/input.txt";
  open(INFILE, "> $input_line")
    or throw saliweb::frontend::InternalError("Cannot open $input_line: $!");
  print INFILE "$receptorFileName $ligandFileName --saxs $profileFileName --complex_type $moltype\n";
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
    #$q->p("Results will be found at <a href=\"" . $job->results_url . "\">this link</a>.");
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
    $return .= $q->p("<a href=\"" . $job->get_results_file_url('fiberdock.log') . "\">View FiberDock log file</a>.");
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

  $return .= "<hr size=2 width=90%>";
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

sub generate_model_pdb {
  my $self = shift;
  my $q = $self->{'CGI'};
  my $dbh = $self->{'dbh'};
  my $job;
  my $file;
  if ($q->path_info =~ m#^/+([^/]+)/*$#) {
    $job = $1;
  } elsif ($q->path_info =~ m#^/+([^/]+)/+(.+)$#) {
    $job = $1;
    $file = $2;
  }
  my $passwd = $q->param('passwd');
  $self->set_page_title("PDB Model");
  if (!defined($job) || !defined($passwd)) {
    throw saliweb::frontend::ResultsBadURLError("Missing job name and password");
  }
  my $query = $dbh->prepare("select * from jobs where name=? and passwd=?")
    or throw saliweb::frontend::DatabaseError("Couldn't prepare query: " . $dbh->errstr);
  $query->execute($job, $passwd)
    or throw saliweb::frontend::DatabaseError("Couldn't execute query: " . $dbh->errstr);
  my $job_row = $query->fetchrow_hashref();
  if (!$job_row) {
    throw saliweb::frontend::ResultsBadJobError("Job does not exist, or wrong password");
  } elsif ($job_row->{state} eq 'EXPIRED'
           || $job_row->{state} eq 'ARCHIVED') {
    throw saliweb::frontend::ResultsGoneError("Results for job '$job' are no longer available");
  } elsif ($job_row->{state} ne 'COMPLETED') {
    throw saliweb::frontend::ResultsStillRunningError("Job '$job' has not yet completed; please check back later");
  } else {
    chdir($job_row->{directory});
    my $return = '';
    my $passwd = $q->param('passwd');
    my $from = $q->param('from');
    my $to = $q->param('to');
    apply_trans("results_saxs.txt", $from, $to);
    my $pdb_file = "docking_$from.pdb";
    $return .= "Content-type: chemical/x-ras\n\n";
    $return .= `cat $pdb_file`;
    $self->_display_content($return);
  }
}

sub apply_trans {
  my $resFileName = shift;
  my $first = shift;
  my $last = shift;

  my $ligandPdb = "";
  my $receptorPdb = "";

  open(DATA, $resFileName);
  my $home = "$FindBin::Bin";
  my $transNum = 0;
  while(<DATA>) {
    chomp;
    my @tmp=split('\|',$_);
    if($#tmp>0 and $tmp[0] =~/\d/) {
      $transNum++;
      if($transNum >= $first and $transNum <= $last and length $ligandPdb > 0 and length $receptorPdb > 0) {
        # apply transformation on the ligand molecule
        my $currResFile = "docking_$transNum.pdb";
        unlink $currResFile;
        `cat $receptorPdb > $currResFile`;
        #print "$home/pdb_trans $tmp[$#tmp] < $ligandPdb >> $currResFile\n";
        `$home/pdb_trans $tmp[$#tmp] < $ligandPdb >> $currResFile`;
      }
    } else {
      # find the filenames in the output file
      @tmp=split(' ',$_);
      if($#tmp>0) {
        if($tmp[0] =~ /ligandPdb/) {
          $ligandPdb = $tmp[2];
          #print "Ligand PDB: $ligandPdb\n";
        }
        if($tmp[0] =~ /receptorPdb/) {
          $receptorPdb = $tmp[2];
          #print "Receptor PDB: $receptorPdb\n";
        }
      }
    }
  }
}

sub generate_model_page {
  my $self = shift;
  my $q = $self->{'CGI'};
  my $dbh = $self->{'dbh'};
  my $job;
  my $file;
  if ($q->path_info =~ m#^/+([^/]+)/*$#) {
    $job = $1;
    } elsif ($q->path_info =~ m#^/+([^/]+)/+(.+)$#) {
    $job = $1;
    $file = $2;
  }
  my $passwd = $q->param('passwd');
  $self->set_page_title("PDB Model");
  if (!defined($job) || !defined($passwd)) {
    throw saliweb::frontend::ResultsBadURLError("Missing job name and password");
  }
  my $query = $dbh->prepare("select * from jobs where name=? and passwd=?")
    or throw saliweb::frontend::DatabaseError("Couldn't prepare query: " . $dbh->errstr);
  $query->execute($job, $passwd)
    or throw saliweb::frontend::DatabaseError("Couldn't execute query: " . $dbh->errstr);
  my $job_row = $query->fetchrow_hashref();
  if (!$job_row) {
    throw saliweb::frontend::ResultsBadJobError("Job does not exist, or wrong password");
  } elsif ($job_row->{state} eq 'EXPIRED'
           || $job_row->{state} eq 'ARCHIVED') {
    throw saliweb::frontend::ResultsGoneError("Results for job '$job' are no longer available");
  } elsif ($job_row->{state} ne 'COMPLETED') {
    throw saliweb::frontend::ResultsStillRunningError("Job '$job' has not yet completed; please check back later");
  } else {
    chdir($job_row->{directory});
    my $jobobj = new saliweb::frontend::CompletedJob($self, $job_row);
    my $return = '';
    my $passwd = $q->param('passwd');
    my $from = $q->param('from');
    my $to = $q->param('to');
    # generate pdb
    my $pdb_file = "docking_$from.pdb";
    if(! -e $pdb_file) {
      apply_trans("results_saxs.txt", $from, $to);
    }
    # generate SAXS fit image
    my $profile_filename = get_profile_filename();
    run_FoXS($pdb_file, $profile_filename);
    $return .= display_FoXS_output($jobobj, $pdb_file, $profile_filename);
    $self->set_page_title("Model $from");
    $self->_display_web_page($return);
  }
}

sub run_FoXS() {
  my $home = "$FindBin::Bin";
  `$home/foxs @_ >& foxs.log`;
  `/modbase5/home/foxs/www/foxs/gnuplot-4.6.0/src/gnuplot *.plt`;
}

sub display_FoXS_output() {
  my $job = shift;
  my $pdb = shift;
  my $profile_filename = shift;
  my $pdbCode = trimExtension($pdb);
  my $return = '';

  #title
  $return .= "<table><tr>";
  $return .= "<td halign=left><font color=blue><b> $pdbCode Theoretical profile </b></td>\n";
  $return .= "<td halign=right><font color=blue><b> $pdbCode Fit to experimental profile </b></td></tr>\n";

  # profile images
  my $profile_png = "$pdbCode.png";
  $return .= "<tr><td halign=left><img src=\"" . $job->get_results_file_url($profile_png) . "\" height=350></td>\n";
  my $profileFile = trimExtension($profile_filename);
  my $fit_png = "$pdbCode"."_".$profileFile.".png";
  if(-e $fit_png) {
    $return .= "<td halign=right><img src=\"" . $job->get_results_file_url($fit_png) . "\" height=350></td>\n";
  } else {
    $return .= "Profile fit not generated";
  }
  $return .= "</tr><tr>\n";

  # links to profile file
  my $outputFile = "$pdbCode.dat";
  my $resultsFile = "$pdb.dat";
  copy($resultsFile, $outputFile);
   $return .= "<td halign=left> <a href=\"" . $job->get_results_file_url($outputFile) . "\">Profile file</a></td>\n";

  # link to fit file
  my $outputFile2 = "$pdbCode"."_"."$profileFile".".dat";
  $return .= "<td halign=left> <a href= \"" . $job->get_results_file_url($outputFile2) . "\">Experimental profile fit file</a></td>\n";
  $return .= "</tr><tr>\n";

  # print fit data
  $return .= "<td halign=left></td><td>";
  my $line = `grep $pdb foxs.log | grep Chi`;
  my @tmp = split(' ', $line);
  $return .= "\&chi;";
  for(my $i =1; $i <9; $i++) {
    $return .= "$tmp[$i+2] ";
  }
  $return .= "</td>\n";
  $return .= "</tr></table>\n";

  return $return;
}

sub get_profile_filename() {
  my $filename = "input.txt";
  open FILE, "<$filename" or die "Can't open file: $filename";
  my @dataFile = <FILE>;
  my $dataLine = $dataFile[0];
  chomp($dataLine);
  my @data = split(' ',$dataLine);
  return $data[3];
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

sub check_required_email {
  my ($email) = @_;
  if($email !~ m/^[\w\.-]+@[\w-]+\.[\w-]+((\.[\w-]+)*)?$/ ) {
    throw saliweb::frontend::InputValidationError("Please provide a valid return email address");
  }
}

sub get_pdb_chains {
  my $self = shift;
  my $pdb_chain = shift;
  my $jobdir = shift;
  my @input = split('\:', $pdb_chain);
  my $pdb_code = lc $input[0];
  my $pdb_file_name = "pdb" . $pdb_code . ".ent";
  my $full_path_pdb_file_name = saliweb::frontend::get_pdb_code($pdb_code, $jobdir);
  if($#input == 0 or $input[1] eq "-") { #no chains given
    return $pdb_file_name;
  }
  # get chains - check if they exist in PDB
  my $chain_id = uc $input[1];
  if($chain_id !~ /^\w*$/) {
    throw saliweb::frontend::InputValidationError("Invalid chain id $chain_id\n");
  }
  my @userchains = split(//,$chain_id);
  my %chains= ();

  open FILE, $full_path_pdb_file_name;
  while (my $line=<FILE>){
    if($line =~ /^ATOM/ || $line =~ /^HETATM/) {
      if(!(substr($line,21,1) =~ ' ')){
        $chains{substr($line,21,1)}=substr($line,21,1)." ";
      }
    }
  }
  close FILE;

  foreach my $userchain (@userchains) {
    if(not exists $chains{$userchain} ) {
      throw saliweb::frontend::InputValidationError("invalid PDB chain $userchain");
      # remove PDB file
      unlink $full_path_pdb_file_name;
      return;
    }
  }

  # get chains
  open FILE, $full_path_pdb_file_name;
  my $out_pdb_file_name = $jobdir . "/" . $input[0] . $chain_id . ".pdb";
  open OUT, ">$out_pdb_file_name";
  while (my $line=<FILE>){
    if($line =~ /^ATOM/|| $line =~ /^HETATM/) {
      my $curr_chain_id = substr($line,21,1);
      if($chain_id =~ m/$curr_chain_id/) {
        print OUT "$line";
      }
    }
  }
  close FILE;
  close OUT;
  # remove PDB file
  unlink $full_path_pdb_file_name;
  return $input[0] . $chain_id . ".pdb";
}

sub get_pdb_code {
  my ($code, $outdir) = @_;
    my $pdb_root = "/netapp/database/pdb/remediated/pdb/";
    if ($code =~ m/^([A-Za-z0-9]+)$/) {
      $code = $1;
    } else {
      throw saliweb::frontend::InputValidationError(
                 "You have entered an invalid PDB code $code; valid codes " .
                 "contain only letters and numbers, e.g. 1abc...");
    }

    my $in_pdb = $pdb_root . substr($code, 1, 2) . "/pdb" . $code . ".ent.gz";
    my $out_pdb = "$outdir/pdb${code}.ent";

    if (! -e $in_pdb) {
      throw saliweb::frontend::InputValidationError(
                 "PDB code '$code' does not exist in our copy of the " .
                 "PDB database.");
    } else {
        system("gunzip -c $in_pdb > $out_pdb") == 0 or
          throw saliweb::frontend::InternalError(
                                 "gunzip of $in_pdb to $out_pdb failed: $?");
        return $out_pdb;
    }
}


sub removeSpecialChars {
  my $str = shift;
  $str =~ s/[^\w,^\d,^\.]//g;
  return $str;
}

sub removeSpaces {
  my $stringWithSpaces = shift;
  my @letters = split(" ",$stringWithSpaces);
  my $stringWithoutSpaces = join("", @letters);
  return $stringWithoutSpaces;
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
