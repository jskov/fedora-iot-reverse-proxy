# Reverse Proxy RPM for mada.dk on Fedora IOT

[![Copr build status](https://copr.fedorainfracloud.org/coprs/jskov/iot-assistant/package/assistant/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/jskov/iot-assistant/package/assistant/)

I use this RPM for layering in Fedora IOT.

It runs [nginx](https://nginx.org/) in a [Podman Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) with a preliminary service to fix the integration with the system (user setup).

>[!NOTE]
>This project is Open Source. But I am not interested in providing support or help in any form.
>You are welcome to fork it though!

# Dev notes




## Build RPM

Build requires RPM 4.20 so needs to be built on Fedora 41 or newer.

Set up toolbox:

```console
$ toolbox create fedora

$ toolbox enter fedora-41
$ sudo dnf install rpmbuild selinux-policy-devel tito -y
```

Build rpm locally (note that this builds committed data only!):

```console
$ toolbox enter fedora-41
$ cd ROOT OF REPOSITORY
$ rpmlint reverse-proxy.spec
$ tito build --rpm --test
```

Test rpm locally:

```console
$ sudo rpm -i /tmp/tito/x86_64/reverse-proxy-1.0.0-0.git.3.2d74dcb.fc41.x86_64.rpm
```


Update spec version (--keep-version to keep manually maintained version in spec file):

```console
$ tito tag --keep-version
```

Build from repo:

```console
$ copr-cli buildscm --clone-url https://github.com/jskov/fedora-iot-reverse-proxy.git --method tito jskov/iot-reverse-proxy
```


## Installation

### RPM

```console
# The --uninstall allows updating an existing layered rpm (older version)
$ sudo rpm-ostree install /var/home/jskov/layers/reverse-proxy-1.0.0-0.fc42.x86_64.rpm --uninstall assistant

# The policy for enabling service does not appear to work, so:
$ sudo systemctl enable reverse-proxy
$ sudo systemctl enable reverse-proxy-prep
$ sudo systemctl reboot
```

### Firewall

```console
$ sudo firewall-cmd --add-forward-port=port=80:proto=tcp:toport=8080 --permanent
```

## Notes

### Systemd

Tried to use systemd-sysusers but it does not work properly with ostree.

So create users/groups in `reverse-proxy-prep` service.

### RPM sources

Built by Tito from last commit,

### Manual Test Runs


```console
# Get the command being executed from systemctl:
$ sudo systemctl status reverse-proxy >/tmp/a

# Then try to run it:
$ sudo su - reverse-proxy
$ /usr/bin/podman xxx
```
