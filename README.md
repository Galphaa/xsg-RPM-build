RPM building script 

Using guide

$1 = target_name.spec 

$2 = architecture_(x86_64) 

$3 = target_name

example

bash build.sh check_linux_interface.pl.spec x86_64 check_linux_interface.pl

for debugging use bash -x 

following dependency should be installed: rpm-build rpmdevtools wget
