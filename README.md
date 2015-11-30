# Bugzilla Demo

This demo creates a Bugzilla application on HPE Helion Stackato.

It is based on Bugzilla-4.0.2 and includes additional patches as well
as experimental changes to make it PSGI compatible.

Only the required modules are included in this demo; optional
functionality is not installed. The scheduled tasks are not configured
in the default sample, but you can add them to a [cron
section](http://docs.stackato.com/deploy/index.html#deploy-crontab) in
the `manifest.yml` file.

## Configuring Bugzilla

If you are pushing this sample from the command line, update the
`myconfig.pl` file with your desired settings (SMTP server, admin
credentials, etc.) before pushing the application to HPE Helion Stackato. Once the
MySQL database has been created on the HPE Helion Stackato cloud, the `myconfig.pl`
file should no longer be modified. All further customization should
happen via the Bugzilla web interface.

If you are deploying from the HPE Helion Stackato App Store, the default Admin
account credentials are:

 * login: admin@example.com
 * password: changeme
 
These, along with the email settings, should be changed as soon as
possible in the web interface under Administration->Parameters.

## Deploying on HPE Helion Stackato

    $ git clone git://github.com/Stackato-Apps/bugzilla.git
    $ cd bugzilla

Verify the settings in `manifest.yml` and `myconfig.pl` then run:

    $ stackato push -n

