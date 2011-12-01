# Bugzilla Demo

This demo creates a Bugzilla application on Stackato.

It is based on Bugzilla-4.0.2 and includes additional patches as well
as experimental changes to make it PSGI compatible.

Only the required modules are included in this demo; optional
functionality is not installed.  Since Stackato doesn't yet support
cron jobs, none of the scheduled tasks are configured either.

## Configuring Bugzilla

Bugzilla can be configured by updating the `myconfig.pl` file before
pushing the application to Stackato.  Once the MySQL database has been
created on the Stackato cloud, the `myconfig.pl` file should no longer
be modified.  Instead all further customization should happen via the
Bugzilla web interface.

## Deploying Bugzilla

Verify the settings in `stackato.yml` and `myconfig.pl` and then publish
by running:

  $ stackato push -n
