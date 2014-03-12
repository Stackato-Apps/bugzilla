use strict;
use warnings;

use ActiveState::Run qw(run);
use LWP::Simple qw(mirror);
use JSON qw(decode_json);
use version;

# Fetch Bugzilla source code
my $LATEST = "http://ftp.mozilla.org/pub/mozilla.org/webtools/bugzilla-4.0.2.tar.gz";
my $tarball = "bugzilla.tar.gz";

unlink($tarball);
mirror($LATEST, $tarball);
die unless -f $tarball;

# Extract Bugzilla sources into bugzilla/ directory
run("tar xfz $tarball");
my ($tardir) = grep -d, <bugzilla-*>;
unlink($tarball);
die unless $tardir;

my $bugzilla_dir = "bugzilla";
run("rm -rf $bugzilla_dir");
run("mv $tardir $bugzilla_dir");

# Configure Bugzilla from inside the app directory
print "cd $bugzilla_dir\n";
chdir($bugzilla_dir);

# Apply fix for https://bugzilla.mozilla.org/show_bug.cgi?id=678772
my $PATCH = "http://bzr.mozilla.org/bugzilla/4.0/diff/7644";
my $diff_file = "7644.diff";
mirror($PATCH, $diff_file);
die unless -f $diff_file;

run("patch -p0 < $diff_file");
unlink $diff_file;

# Apply a slightly modified patch to make Bugzilla work with PSGI
# Bug 316665 - Make Bugzilla work with FastCGI
# https://bugzilla.mozilla.org/show_bug.cgi?id=316665#c18
run("patch -p1 < ../psgi.patch");

# Just to have the diagnostic output in the staging log
run("$^X ./checksetup.pl --check-modules");

# Create an "answer" file for checksetup.pl to configure MySQL
# and to setup the initial administrator account.
our %answer;
do '../myconfig.pl';

my($user,$password,$host,$port,$name) = $ENV{MYSQL_URL} =~ m{mysql://(.+?):(.+?)\@(.+?):(\d+?)/(.*?)$}
    or die "MySQL service not configured";

%answer = (
    NO_PAUSE       => 1,
    db_driver      => 'mysql',
    db_host        => $host,
    db_name        => $name,
    db_pass        => $password,
    db_port        => $port,
    db_user        => $user,
    webservergroup => 'stackato',

    mail_delivery_method => 'SMTP',
    %answer
);

# Make sure urlbase ends with a slash
$answer{urlbase} =~ s,(.*[^/])$,$1/,;

my $answer = "checksetup.answer";
open my $fh, ">", $answer or die "Can't write '$answer': $!";
print $fh qq(\$answer{$_} = "\Q$answer{$_}\E";\n) for sort keys %answer;
close $fh;

# First run of checksetup.pl will update localconfig file.
# Second run will actually configure the database and
# create the admin user.
run("$^X ./checksetup.pl $answer") for 1..2;
