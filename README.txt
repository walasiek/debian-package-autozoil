Requirements
============

Install:

sudo apt-get install build-essential devscripts ubuntu-dev-tools debhelper dh-make diff patch cdbs quilt gnupg fakeroot lintian  pbuilder piuparts dh-make-perl

Install cpan module Markdown::Pod:
sudo cpan -f -i Markdown::Pod 

Create package
==============

Requirements
------------

First you have to create and install languagetool package:

* cd languagetool-package
* sudo ./create-new-package.sh
* sudo dpkg -i packages/languagetool_1.7_all.deb

Create Autozoil package
-----------------------

Run ./create-new-package.sh x.y.z
where x.y.z is a version number.

The package will be saved in the packages directory.

