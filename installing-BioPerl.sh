#!/bin/bash
# This is a tip to install BioPerl on CentOS 6.7

# CPAN tries to install these perl modules. 
# However yum prevent to install them.
# So I will install them using yum.
# You may need to install some other modules.

echo "Installing perl modules"
sudo yum -y install perl-CPAN expat21-devel perl-DBD-MySQL gd perl-IO-Compress-Bzip2 \
    perl-XML-Parser perl-libxml-perl perl-libxml-perl perl-GraphViz \
    perl-Archive-Tar perl-Archive-Zip perl-Text-Glob perl-Test-MockModule \
    perl-ExtUtils-CBuilder perl-IO-Compress-Base perl-Module-Build \
    perl-Test-Most perl-Exception-Class perl-Class-Data-Inheritable \
    perl-Capture-Tiny perl-ExtUtils-* perl-version perl-CPAN-Meta-YAML # for bioperl

echo "Setup for installing BioPerl"
sudo perl -MCPAN -e shell <<EOF
install Bundle::CPAN
install Module::Build
o conf prefer_installer MB
o conf commit
EOF

echo "Installing BioPerl"
sudo perl -MCPAN -e shell <<EOF
force install CJFIELDS/BioPerl-1.6.924.tar.gz
EOF

echo "Checking if the BioPerl is installed successfully"
perl -MBio::Perl -le 'print $Bio::Perl::VERSION'
