Mistral RTM Plug-in
===================

Intro
-----
This plug-in receives violation data from Mistral and enters it into a MySQL/MariaDB database named
"mistral_log" in a format expected by IBM RTM. MySQL/MariaDB client libraries must be installed on
every machine that will run jobs under Mistral.

Process Summary
---------------
The schema creation script creates a database called "mistral_log". Within it are 2 tables:
the mistral_events table and a mistral_rule_parameters table. A user "'mistral'@'%'" is created and
granted all privileges on "mistral_log".

The plug-in uses a single table to store Mistral data with data rotation handled by the LSF Spectrum
RTM system. The data is the same as would be output from Mistral to a log file. Each field is stored
in a separate column with the exception of those stored in the "mistral_rule_parameters" table (see
below).

The "mistral_rule_parameters" table converts unique combinations of "Label, Violation path,
Call-Type, Size-Range, Measurement and Threshold" into integer indexes which are then stored in the
events table. The mistral_rule_parameters table is never cleared.

Password Hiding
---------------
MySQL requires a password for each user. If scripts are to be run automatically, the easiest way
to protect passwords is to include them in a config file and change the permissions of this file
to be read only to the user. MySQL can read in a config file using the tag "--defaults-file=".
This config file should be of the format ::

    [client]
    user=mistral
    password=mistral
    host=localhost
    port=3306
    database=mistral_log


Set-Up Instructions
-------------------
From a terminal on the host machine designated to house the database, run ::

    mysql -u root -p < create_mistral.sql

And enter the password to the root user account. This will create the database schema and the
related mistral user. Any user with sufficient privileges to create both databases and users can be
used in place of the root account.

