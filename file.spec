Name: 		__NAME__
Version:        __VERSION__
Release:        __RELEASE__
Summary:  sample 
License:  GPL
URL:      none      
Source0:   %{name}-%{version}.tar.gz     
BuildRoot: __PATH__/rpmbuild/%{name}-%{version}-%{release}-buildroot

Prefix: %{_prefix}


%description


%prep

%setup -q -n %{name}-%{version}


%install
rm -rf "$RPM_BUILD_ROOT"
mkdir -p "$RPM_BUILD_ROOT/opt/%{name}"
cp -R * "$RPM_BUILD_ROOT/opt/%{name}"
%files
/opt/file

%clean 
rm -rf "$RPM_BUILD_ROOT"
