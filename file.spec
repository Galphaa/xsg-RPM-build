Name: 		__NAME__
Version:        __VERSION__
Release:        __RELEASE__
Summary:  sample 
License:  GPL
URL:      none      
Source0:   __FILE__.tar.gz     
BuildRoot: __PATH__/rpmbuild/%{name}-%{version}-%{release}-buildroot

Prefix: %{_prefix}


%description


%prep
%setup -n __FILE__


%install
rm -rf "$RPM_BUILD_ROOT"
mkdir -p "$RPM_BUILD_ROOT/opt/file"
cp -R * "$RPM_BUILD_ROOT/opt/file"
%files
/opt/file

%clean 
r -rf $RPM_BUILD_ROOT
