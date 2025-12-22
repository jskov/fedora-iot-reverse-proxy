Name: reverse-proxy
Version: 1.29.4
Release: 0%{?dist}
Summary: Reverse proxy for mada.dk

License: EUPL-1.2
URL: https://github.com/jskov/fedora-iot-reverse-proxy

Source0: %{name}-%{version}.tar.gz

# See https://docs.fedoraproject.org/en-US/packaging-guidelines/Scriptlets/#_systemd
BuildRequires: systemd-rpm-macros

%description

Reverse Proxy configuration for mada.dk, running in a Systemd container on Fedora IoT.

%global debug_package %{nil}

%prep
%setup -q

%build

image=$(grep '^FROM' Containerfile | cut -d' ' -f 2)
cat reverse-proxy.container | sed -e "s,@NGINX_IMAGE@,$image," > %{_builddir}/reverse-proxy.container

%install

rm -f %{buildroot}/etc/containers/systemd/users/3010/reverse-proxy.container
rm -f %{buildroot}/usr/lib/systemd/system/reverse-proxy-prep.service
rm -f %{buildroot}/usr/share/mada/reverse-proxy

install -Dp -m644 reverse-proxy-prep.service %{buildroot}/usr/lib/systemd/system/reverse-proxy-prep.service
install -Dp -m644 %{_builddir}/reverse-proxy.container %{buildroot}/etc/containers/systemd/users/3010/reverse-proxy.container
install -Dp -m644 nginx.conf %{buildroot}/usr/share/mada/reverse-proxy/nginx.conf
install -Dp -m644 index.html %{buildroot}/usr/share/mada/reverse-proxy/web/index.html

%pre

%post
%systemd_post reverse-proxy-prep

%preun
%systemd_preun reverse-proxy-prep

%postun
%systemd_postun_with_restart reverse-proxy-prep

%files

/usr/lib/systemd/system/reverse-proxy-prep.service
/etc/containers/systemd/users/3010/reverse-proxy.container
/usr/share/mada/reverse-proxy/web/index.html
/usr/share/mada/reverse-proxy/nginx.conf

%changelog
* Mon Dec 22 2025 Jesper Skov <jskov@mada.dk> 1.29.4-0
- new package built with tito

* Mon Dec 22 2025 Jesper Skov <jskov@mada.dk> 1.29.4-0
- new package built with tito

* Wed Apr 09 2025 Jesper Skov <jskov@mada.dk> 1.0.0
- First release
- Add first reverse proxy entries (jskov@mada.dk)
