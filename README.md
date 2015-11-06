
### Thanks GOTO 

The code contained here is a largely modified version of original code found in the following repository
https://github.com/farrellit/shell-assume-aws-role.git

# Introduction

This code is designed to be run from the unix shell command line and can be used as a quick method to assume an AWS role and can aid in the implementation of cross account access by making the process of assuming a role that much simpler

# Pre-Reqs

This role assumes that the AWS CLI command line tools are installed and that you have already setup cross account authentication and have the resource identifier (beginning arn::iam::) of the role you wish to assume.

Remembering each role name via the resource identifier is tedious and therefore this program can utilise a "roles" file placed within $HOME/.aws where you can place alias names for the resource.  Thus an entry in the roles file of:

<pre>
devadmin   arn:aws:iam::01234567890:role/administrator
</pre>

will actually allow you to refer to the role via "devadmin" instead of using the resource identifier.  Of course if you want to use the resource name go ahead as the code will only look for the shortname if the role name doesn't begin with arn::

This program needs to run as a function within the current shell in order that the environment variables persist.  Therefore it must be sourced.  The most efficient way to source this is to add code to the .bash_profile & .bashrc (or any other shell initiation script) to ensure it is sourced either at a new login or on execution of a new shell environment.   To achieve this simply add the following to these files
<pre>
source (location_of_program)/assume_role.sh
</pre>
replacing (location_of_program) with the folder location you installed this program under.

# Usage
 
## Assuming a role

assume -r (role) [ -t (token) -P (profile) -R (region) ]

The only option in the above which is mandatory is (role) which must be either the resource identifier (arn::) or the alias to the role (ie devadmin) taken from the roles file.  

If (profile) is not chosen then "default" is used (taken from $HOME/.aws/config) and if (region) is not chosen this defaults to eu-west-1 (feel free to update the code to change this as desired) and if (token) is not provided then you will be prompted to supply an MFA code
 
### Examples
Remember that if you haven't already sourced this function via the method described above you must source this manually first before running

#### Assuming a role using the alias from the roles file
<pre>
source assume_role.sh (if not sourced already)
assume -r devadmin
</pre>

#### Assuming a role using the full arm
<pre>
source assume_role.sh (if not sourced already)
assume -r arn:aws:iam::01234567890:role/administrator
</pre>

#### Assuming a role using the role alias and non-default options
<pre>
source assume_role.sh (if not sourced already)
assume -r devadmin -P dev -R us-west-1 -t 123456
</pre>

## Uassuming a role

unassume (-s|silent)

After you have assumed a role you are effectively stuck in the assumed environment until your access keys expire and you wipe the environment variables so that you can return to the default state.  Running the "unassume" function simply wipes the variables created by the "assume" function.  In fact "assume" runs "unassume" before it runs in order to clean the environment before attempting to assume a role.  Running "unassume" with the "-s" or "silent" options simply supress any output (which is what happens when the "assume" function calls it)

### Examples
####Unassuming a role
<pre>
source assume_role.sh (if not sourced already)
unassume
Role unassumed
</pre>

####Unassuming a role silently
<pre>
source assume_role.sh (if not sourced already)
unassume -s
</pre>

## Listing roles

liststsroles

It is very likely that you won't remember all of the roles you assume, even if you do use role alises, especially if you assume many.  If you make use of the roles file as described above you can query the roles you have configured using the "liststsroles" function

### Examples
####Listing roles
<pre>
source assume_role.sh (if not sourced already)
liststsroles
devadmin	arn:aws:iam::01234567890:role/administrator
testadmin	arn:aws:iam::11111111111:role/administrator
</pre>

# Contributions

Please feel free to download and use this code or provide feedback and contribute via a pull request
