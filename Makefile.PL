use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'version::Limit',
    VERSION_FROM      => 'lib/version/Limit.pm', # finds $VERSION
    PREREQ_PM         => {version => 0.35}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/version/Limit.pm', # retrieve abstract from module
       AUTHOR         => 'John Peacock <jpeacock@cpan.org>') : ()),
    dist               => {
       PREOP => 'svn log > ${DISTVNAME}/Changes',
                          },
);
