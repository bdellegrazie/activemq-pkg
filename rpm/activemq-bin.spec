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
Source1:	http://repo1.maven.org/maven2/org/apache/activemq/activemq-rar/%{version}/activemq-rar-%{version}.rar
Patch0:		check_piddir.patch

Requires(pre):	shadow-utils
Requires:	jre-1.8.0

%description
ActiveMQ Messaging Software

%prep
%autosetup -n %{source_name}-%{version} -p1

%build
# set correct defaults in wrapper config


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{base_dir}/data/
mkdir -p %{buildroot}%{_var}/log/%{short_name}/
mkdir -p %{buildroot}%{_sysconfdir}/%{short_name}/
mkdir -p %{buildroot}%{_sysconfdir}/sysconfig/
mkdir -p %{buildroot}%{_initddir}/
cp -a %{SOURCE1} -t %{buildroot}%{base_dir}
cp -a *.jar bin lib webapps -t %{buildroot}%{base_dir}/
cp -a conf/* -t %{buildroot}%{_sysconfdir}/%{short_name}/
# Should check for arch here but the directory names are inconsistent
cp -a bin/%{_os}-%{activemq_arch}/wrapper.conf %{buildroot}%{_sysconfdir}/%{short_name}-wrapper.conf
ln -sf -T %{_sysconfdir}/%{short_name}-wrapper.conf %{buildroot}%{base_dir}/bin/%{_os}-%{activemq_arch}/wrapper.conf
ln -s %{base_dir}/bin/%{_os}-%{activemq_arch}/%{short_name} %{buildroot}%{_initddir}/%{short_name}
cat > %{buildroot}%{_sysconfdir}/sysconfig/%{short_name} <<'END'
# ActiveMQ Locations
export ACTIVEMQ_HOME="/opt/%{short_name}"
export ACTIVEMQ_BASE="/opt/%{short_name}"
export ACTIVEMQ_CONF="%{_sysconfdir}/%{short_name}"
export ACTIVEMQ_DATA="$ACTIVEMQ_BASE/data"

# Location of the pid file.
PIDDIR="%{_var}/run/%{short_name}"

# User to execute wrapper as
RUN_AS_USER=%{short_name}
END

%pre
getent group %{short_name} >/dev/null || groupadd -r %{short_name}
getent passwd %{short_name} >/dev/null || \
    useradd -r -g %{short_name} -M -d %{base_dir} -s /bin/bash \
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
%{base_dir}/*.rar
%{base_dir}/bin/*
%attr(0750,%{short_name},%{short_name}) %dir %{base_dir}/data/
%{base_dir}/lib/*
%{base_dir}/webapps/*
%config %{_initddir}/%{short_name}
%config(noreplace) %attr(0640,-,%{short_name}) %{_sysconfdir}/%{short_name}-wrapper.conf
%config(noreplace) %{_sysconfdir}/sysconfig/%{short_name}
%defattr(0640,%{short_name},%{short_name},0750)
%config(noreplace) %{_sysconfdir}/%{short_name}/

%changelog
* Wed Feb 10 2016 Brett Delle Grazie <brett.dellegrazie@indigoblue.co.uk> - 5.13.1-1
- Initial version of the package
