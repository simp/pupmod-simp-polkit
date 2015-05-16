Summary: PolicyKit Puppet Module
Name: pupmod-polkit
Version: 4.1.0
Release: 1
License: Apache License, Version 2.0
Group: Applications/System
Source: %{name}-%{version}-%{release}.tar.gz
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: pupmod-concat >= 4.0.0-0
Requires: puppet >= 3.3.0
Requires: puppetlabs-stdlib >= 4.1.0
Buildarch: noarch
Requires: simp-bootstrap >= 4.2.0
Obsoletes: pupmod-polkit-test

Prefix:"/etc/puppet/environments/simp/modules"

%description
This Puppet module provides for the management of PolicyKit rules.

%prep
%setup -q

%build

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/polkit

dirs='files lib manifests templates'
for dir in $dirs; do
  test -d $dir && cp -r $dir %{buildroot}/%{prefix}/polkit
done

mkdir -p %{buildroot}/usr/share/simp/tests/modules/polkit

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

mkdir -p %{buildroot}/%{prefix}/polkit

%files
%defattr(0640,root,puppet,0750)
/etc/puppet/environments/simp/modules/polkit

%post
#!/bin/sh

if [ -d /etc/puppet/environments/simp/modules/polkit/plugins ]; then
  /bin/mv /etc/puppet/environments/simp/modules/polkit/plugins /etc/puppet/environments/simp/modules/polkit/plugins.bak
fi

%postun
# Post uninstall stuff

%changelog
* Fri Jan 16 2015 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.1.0-1
- Changed puppet-server requirement to puppet

* Tue Apr 08 2014 Kendall Moore <kmoore@keywcorp.com> - 4.1.0-0
- Refactored manifests to pass all lint tests for puppet 3 and hiera compatibility.
- Added spec tests.

* Mon Oct 07 2013 Kendall Moore <kmoore@keywcorp.com> - 4.0.0-3
- Updated all erb templates to properly scope variables.

* Thu Jul 04 2013 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-2
- There was a bug in the 'identity' variable for polkit::local_authority where
  it would not properly accept arrays of users or groups.

* Thu Dec 31 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-1
- Created a Cucumber test that includes module in manifest and checks for config files.

* Fri Oct 26 2012 Trevor Vaughan <tvaughan@onyxpoint.com> - 4.0.0-0
- Initial module release
