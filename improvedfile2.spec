Name: 		check_linux_interface.pl
Version:        20170301
Release:        135328
Summary:  sample 
License:  GPL
URL:      none      
Source0:   %{name}-%{version}.tar.gz     
BuildRoot: /tmp/tmp.w71VL5TouZ/rpmbuild/%{name}-%{version}-%{release}
#-buildroot

Prefix: %{_prefix}


%description


%prep
%setup -q  -n %{name}


%install
rm -rf "$RPM_BUILD_ROOT"
mkdir -p "$RPM_BUILD_ROOT/opt/file"
cp -R * "$RPM_BUILD_ROOT/opt/file"
%files
/opt/file

%clean 
rm -rf "$RPM_BUILD_ROOT"
