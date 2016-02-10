%global source_name apache-activemq
%global short_name  activemq
%global base_dir    /opt/%{short_name}
%global activemq_arch  %{lua: print(string.gsub(rpm.expand("%{_build_arch}"),"_","-").."")}

Name:		activemq-bin
Version:	%{VERSION}
Release:	%{ITERATION}%{?dist}
Summary:	Apache ActiveMQ
Group:		misc
AutoReqProv:    no
License:	Apache License v2.0
URL:		http://activemq.apache.org/
Source0:	http://archive.apache.org/dist/%{source_name}/%{version}/%{source_name}-%{version}-bin.tar.gz
Patch0:		check_piddir.patch

Requires(pre):	shadow-utils
Requires:	jre-1.8.0

%description
ActiveMQ Messaging Software

%prep
%autosetup -n %{source_name}-%{version} -p1

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{base_dir}/data/
mkdir -p %{buildroot}%{_var}/log/%{short_name}/
mkdir -p %{buildroot}%{_sysconfdir}/%{short_name}/
mkdir -p %{buildroot}%{_sysconfdir}/sysconfig/
mkdir -p %{buildroot}%{_initddir}/
cp -a conf/* -t %{buildroot}%{_sysconfdir}/%{short_name}/
# Should check for arch here but the directory names are inconsistent
ln -s %{base_dir}/bin/%{_os}-%{activemq_arch}/wrapper.conf %{buildroot}%{_sysconfdir}/%{short_name}-wrapper.conf
ln -s %{base_dir}/bin/%{_os}-%{activemq_arch}/%{short_name} %{buildroot}%{_initddir}/%{short_name}
cp -a *.jar bin lib webapps -t %{buildroot}%{base_dir}/
cat > %{buildroot}%{_sysconfdir}/sysconfig/%{short_name} <<'END'
# ActiveMQ Home
ACTIVEMQ_HOME="/opt/%{short_name}"

# Location of the pid file.
PIDDIR="%{_var}/run/%{short_name}"

# User to execute wrapper as
RUN_AS_USER=%{short_name}
END

%pre
getent group %{short_name} >/dev/null || groupadd -r %{short_name}
getent passwd %{short_name} >/dev/null || \
    useradd -r -g %{short_name} -M -d %{base_dir}-s /sbin/nologin \
    -c "ActiveMQ Service Account" %{short_name}
exit 0

%preun
if [ $1 -eq 0 ] ; then
  if [ -f /etc/rc.d/init.d/%{short_name} ] ; then
    /sbin/service %{short_name} stop
  fi
  /sbin/chkconfig --del %{short_name}
fi

%files
%doc README.txt NOTICE docs/*
%license LICENSE
%dir %{base_dir}/
%{base_dir}/*.jar
%{base_dir}/bin/*
%attr(0750,%{short_name},%{short_name}) %{base_dir}/data/
%{base_dir}/lib/*
%{base_dir}/webapps/*
%config %{_initddir}/%{short_name}
%config(noreplace) %attr(0640,-,-) %{_sysconfdir}/%{short_name}-wrapper.conf
%config(noreplace) %{_sysconfdir}/sysconfig/%{short_name}
%defattr(0750,%{short_name},root,0644)
%config(noreplace) %{_sysconfdir}/%{short_name}/

%changelog
* Wed Feb 10 2016 Brett Delle Grazie <brett.dellegrazie@indigoblue.co.uk> - 5.13.1-1
- Initial version of the package
