Name: check_interface.pl
Version:        __VERSION__
Release:        __RELEASE__
summary:  sample 
License:  GPL
URL:      none      
Source0:   file.tar.gz     
BuildRoot: /home/rpmbuild/%{name}-%{version}-%{release}-buildroot

Prefix: %{_prefix}


%description


%prep
%setup -n file

%install
rm -rf "$RPM_BUILD_ROOT"
mkdir -p "$RPM_BUILD_ROOT/opt/file"
cp -R * "$RPM_BUILD_ROOT/opt/file"
%files
/opt/file

%clean 
rm -rf $RPM_BUILD_ROOT
