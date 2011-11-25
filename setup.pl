use strict;
use warnings;

use ActiveState::Run qw(run);
use LWP::Simple qw(mirror);
use JSON qw(decode_json);
use version;

# Fetch Bugzilla source code
my $LATEST = "https://ftp.mozilla.org/pub/mozilla.org/webtools/bugzilla-4.0.2.tar.gz";
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
my $PATCH = "https://bzr.mozilla.org/bugzilla/4.0/diff/7644";
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

# Locate credentials for the "mysql-bugzilla" service
die "No services configured" unless defined $ENV{VCAP_SERVICES};
my $services = decode_json($ENV{VCAP_SERVICES});
die "No MySQL service configured" unless $services->{"mysql-5.1"};

my($mysql) = grep $_->{name} eq "mysql-bugzilla", @{$services->{"mysql-5.1"}};
my %cred = %{$mysql->{credentials}};


# Create an "answer" file for checksetup.pl to configure MySQL
# and to setup the initial administrator account.
my %answer = (
    ADMIN_EMAIL    => 'admin@example.com',
    ADMIN_PASSWORD => 'changeme',
    ADMIN_REALNAME => 'Sample Admin',
    NO_PAUSE       => 1,
    db_driver      => 'mysql',
    db_host        => $cred{host},
    db_name        => $cred{name},
    db_pass        => $cred{password},
    db_port        => $cred{port},
    db_user        => $cred{user},
    webservergroup => 'stackato',

    mail_delivery_method => 'SMTP',
    mailfrom             => "bugzilla-daemon\@example.com",
    smtpserver           => "smtp.example.com",
);

my $answer = "checksetup.answer";
open my $fh, ">", $answer or die "Can't write '$answer': $!";
print $fh qq(\$answer{$_} = "\Q$answer{$_}\E";\n) for sort keys %answer;
close $fh;

# First run of checksetup.pl will update localconfig file.
# Second run will actually configure the database and
# create the admin user.
run("$^X ./checksetup.pl $answer") for 1..2;
