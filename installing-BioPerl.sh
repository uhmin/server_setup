#!/bin/bash
# This is a tip to install BioPerl on CentOS 6.7

# CPAN tries to install these perl modules. 
# However yum prevent to install them.
# So I will install them using yum.
# You may need to install some other modules.
sudo yum -y install perl-CPAN expat21-devel perl-DBD-MySQL gd \
    perl-XML-Parser perl-libxml-perl perl-libxml-perl perl-GraphViz \
    perl-Archive-Tar perl-Archive-Zip perl-Text-Glob perl-Test-MockModule \
    perl-ExtUtils-CBuilder perl-IO-Compress-Base perl-Module-Build # for bioperl

sudo perl -MCPAN -e shell <<EOF
install Bundle::CPAN
install Module::Build
o conf prefer_installer MB
o conf commit
force install CJFIELDS/BioPerl-1.6.924.tar.gz
EOF
