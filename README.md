# Bugzilla Demo

This demo creates a Bugzilla application on Stackato.

It is based on Bugzilla-4.0.2 and includes additional patches as well
as experimental changes to make it PSGI compatible.

Only the required modules are included in this demo; optional
functionality is not installed. The scheduled tasks are not configured
in the default sample, but you can add them to a [cron
section](http://docs.stackato.com/deploy/index.html#deploy-crontab) in
the `stackato.yml` file.

## Configuring Bugzilla

If you are pushing this sample from the command line, update the
`myconfig.pl` file with your desired settings (SMTP server, admin
credentials, etc.) before pushing the application to Stackato. Once the
MySQL database has been created on the Stackato cloud, the `myconfig.pl`
file should no longer be modified. All further customization should
happen via the Bugzilla web interface.

If you are deploying from the Stackato App Store, the default Admin
account credentials are:

 * login: admin@example.com
 * password: changeme
 
These, along with the email settings, should be changed as soon as
possible in the web interface under Administration->Parameters.

## Deploying Bugzilla

Verify the settings in `stackato.yml` and `myconfig.pl` then run:

  $ stackato push -n

