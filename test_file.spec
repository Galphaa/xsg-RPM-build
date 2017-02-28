Name: 		check_linux_interface.pl
Version:        20170228
Release:        084807
Summary:  sample 
License:  GPL
URL:      none      
Source0:   check_linux_interface.pl.tar.gz     
BuildRoot: %{_tmppath}/%{name}–%{version}–%{release}-root-%(%{__id_u} -n)




%description


%prep
%setup -n check_linux_interface.pl

%install
rm -rf "$RPM_BUILD_ROOT"
mkdir -p "$RPM_BUILD_ROOT/opt/check_linux_interface.pl"
cp -R * "$RPM_BUILD_ROOT/opt/check_linux_interface.pl"

%files
/opt/check_linux_interface.pl

%clean 
