Name:           __NAME__
Version:        __VERSION__
Release:        __RELEASE__
Summary:  sample
License:  GPL
URL:      none
Source0:   %{name}-%{version}.tar.gz
BuildRoot: %_tmppath/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


%description


%prep

%setup -q -n %{name}-%{version}


%install
install -d  %{buildroot}
%{__cp} -ad ./* %{buildroot}

%clean
rm -rf "$RPM_BUILD_ROOT"

%files
%defattr(-,root,root)
/usr/lib64/nagios-plugins/__NAME__

%changelog
* Fri Mar 03 2017 Konstantine Karosanidze <konstantine.karosanidze@gmail.com>
- Initial Build
