# Home Assistant RPM for Fedora IOT

[![Copr build status](https://copr.fedorainfracloud.org/coprs/jskov/iot-assistant/package/assistant/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/jskov/iot-assistant/package/assistant/)

I use this RPM for layering in Fedora IOT.

It runs [Home Assistant](https://www.home-assistant.io/) in a [Podman Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) with a preliminary service to fix the integration with the system (user setup and USB access).

>[!NOTE]
>This project is Open Source. But I am not interested in providing support or help in any form.  
>You are welcome to fork it though!

# Dev notes


## Build RPM

Build requires RPM 4.20 so needs to be built on Fedora 41 or newer.

Set up toolbox:

```console
$ toolbox create fedora-41 -r f41

$ toolbox enter fedora-41
$ sudo dnf install rpmbuild selinux-policy-devel tito -y
```

Build rpm locally:

```console
$ toolbox enter fedora-41
$ cd ROOT OF REPOSITORY
$ rpmlint assistant.spec
$ tito build --rpm --test
```

Update spec version (--keep-version to keep manually maintained version in spec file):

```console
$ tito tag --keep-version
```

Build from repo:

```console
$ copr-cli buildscm --clone-url https://github.com/jskov/fedora-iot-assistant.git --method tito jskov/iot-assistant
```


## Installation

### RPM

```console
# The --uninstall allows updating an existing layered rpm (older version)
$ sudo rpm-ostree install /var/home/jskov/layers/assistant-2024.10.4-0.fc41.x86_64.rpm --uninstall assistant

# The policy for enabling service does not appear to work, so:
$ sudo systemctl enable assistant
$ sudo systemctl enable assistant-prep
$ sudo systemctl reboot
```

### Firewall

```console
$ sudo firewall-cmd --add-port=8123/tcp --permanent
```

## Notes

### Systemd

Tried to use systemd-sysusers but it does not work properly with ostree.

So create users/groups in `assistant-prep` service.

### RPM sources

Install from individual source files instead of an archive of source files. Set [__sourcedir](https://serverfault.com/questions/311440/build-rpm-using-source-directory-not-tarball).

And skip sections:

```text
#%prep
#%setup -q
#%build
```

### Manual Test Runs


```console
# Get the command being executed from systemctl:
$ sudo systemctl status assistant >/tmp/a

# Then try to run it:
$ sudo su - assistant
$ /usr/bin/podman --log-level=debug run --name=assistant --cidfile=/var/run/user/3000/assistant.cid --replace --rm --cgroups=split --sdnotify=conmon -d --device=/dev/ttyUSB0 -v /opt/data/services/assistant:/config:Z,rw --publish 8123:8123 --env TZ=Europe/Copenhagen --group-add=keep-groups --cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE ghcr.io/home-assistant/home-assistant@sha256:a880ef8e77f34b694668e508ecb109b260948025c9ef71073ece9bc809155347
```

### SELinux

Tried setting `container_use_devices` from .spec file with:

```spec
BuildRequires: selinux-policy
BuildRequires: selinux-policy-devel
%{?selinux_requires}

# As per https://fedoraproject.org/wiki/PackagingDrafts/SELinux_Independent_Policy#Setting_Booleans_During_an_Product_Policy_Installation
%global selinuxtype targeted
%global selinuxbooleans container_use_devices=1

%post
%selinux_set_booleans -s %{selinuxtype} %{selinuxbooleans}

%postun
%selinux_unset_booleans -s %{selinuxtype} %{selinuxbooleans}
```

But it did not seem to work on the ostree after reboot.
So went with explicit command in assistant-prep instead.

