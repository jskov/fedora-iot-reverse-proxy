# Reverse Proxy RPM for mada.dk on Fedora IOT

[![Copr build status](https://copr.fedorainfracloud.org/coprs/jskov/iot-reverse-proxy/package/reverse-proxy/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/jskov/iot-reverse-proxy/package/reverse-proxy/)

I use this RPM for layering in Fedora IOT.

It runs [nginx](https://nginx.org/) in a [Podman Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) with a preliminary service to fix the integration with the system (user setup).

>[!NOTE]
>This project is Open Source. But I am not interested in providing support or help in any form.
>You are welcome to fork it though!

# Dev notes

## Testing nginx config

```console
# enter container Pod

# To test local web file access, copy files and change config to use /tmp/web as root
$ mkdir /tmp/web ; cp ./index.html /tmp/web/

$ cp ./nginx.conf  /tmp/ ;  sudo nginx -c /tmp/nginx.conf -g 'daemon off;'
...

$ curl -v -H "host: pihole.mada.dk" localhost:8000
# should respond with data from pihole

$ curl -v localhost:8000
# should respond with data from web-folder
```

## Build RPM

Set up toolbox:

```console
$ distrobox create -i registry.fedoraproject.org/fedora:43 -n fedora-tito --pre-init-hooks "dnf install -y rpmbuild selinux-policy-devel tito"
$ 
```

Build rpm locally (note that this builds on *committed GIT data only!*):

```console
$ distrobox enter fedora-rev-proxy
$ cd ROOT OF REPOSITORY
$ rpmlint reverse-proxy.spec
$ rm -rf /tmp/tito/x86_64/ ; tito build --rpm --test
```

Testing the rpm locally is hard to do on an Atomic OS.
Installation can be tested on a container containing init:

```console
$ distrobox create -i registry.fedoraproject.org/fedora:42 --init --additional-packages "systemd" -n fedora-test
$ distrobox enter fedora-test

$ sudo rpm -i /tmp/tito/x86_64/reverse-proxy-1.0.0-0.git.3.2d74dcb.fc41.x86_64.rpm
```

But `systemctl` does not work with the --machine/--user in this setup.

So test the image installation/system-d interaction on plain Fedora (in a box).
Remember to make `/tmp/tito` available to the Flatpak Boxes application.





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

Install the RPM; the --uninstall allows updating an existing layered rpm (older version):

```console
$ sudo rpm-ostree install /var/home/jskov/layers/reverse-proxy-1.0.0-0.fc42.x86_64.rpm --uninstall reverse-proxy
```

Enable the prep-service; the systemd policy for enabling a service does not appear to work (on Atom?):

```console
$ sudo systemctl enable reverse-proxy-prep
$ sudo systemctl reboot
```

The user process should be running after restart:

```console
$ sudo systemctl --user -M revproxy@ status reverse-proxy
● reverse-proxy.service
     Loaded: loaded (/etc/containers/systemd/users/3010/reverse-proxy.container; generated)
    Drop-In: /usr/lib/systemd/user/service.d
             └─10-timeout-abort.conf
     Active: active (running) since Sun 2025-08-03 09:27:18 CEST; 3min 7s ago
 Invocation: cca68875c12547d1a900859f3eaf0f36
   Main PID: 2300
      Tasks: 11 (limit: 14265)
     Memory: 138.8M (peak: 194.5M)
        CPU: 4.356s
     CGroup: /user.slice/user-3010.slice/user@3010.service/app.slice/reverse-proxy.service
             ├─libpod-payload-675f1a025164f3198ff853deaa928839c1d5dc3188292ff991561aae9697ccee
             │ ├─2302 "nginx: master process nginx -g daemon off;"
             │ ├─2318 "nginx: worker process"
             │ ├─2319 "nginx: worker process"
             │ ├─2320 "nginx: worker process"
             │ ├─2321 "nginx: worker process"
             │ ├─2322 "nginx: worker process"
             │ ├─2323 "nginx: worker process"
             │ ├─2324 "nginx: worker process"
             │ └─2325 "nginx: worker process"
             └─runtime
               ├─2298 /usr/bin/pasta --config-net -t 8080-8080:80-80 --dns-forward 169.254.1.1 -u none -T none -U none --no-map-gw --quiet --netns /run/user/3010/netns/netns-32ef1b12-df81-1a12-d64c-dba4b64b4733 --map-guest-addr 169.254.1.2
               └─2300 /usr/bin/conmon --api-version 1 -c 675f1a025164f3198ff853deaa928839c1d5dc3188292ff991561aae9697ccee -u 675f1a025164f3198ff853deaa928839c1d5dc3188292ff991561aae9697ccee -r /usr/bin/crun -b /home/revproxy/.local/share/containers/storage/overlay-containers/675f1a>
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
### Testing pakcage

**Cleanup**

```console
$ sudo rpm -e reverse-proxy
$ sudo loginctl disable-linger revproxy
$ sudo userdel -r revproxy

$ sudo sh -c 'rpm -e reverse-proxy ; loginctl disable-linger revproxy ; userdel -r revproxy'
```

**Copy to Boxes instance**

NOTE: Remember to make `/tmp/tito` available to the Flatpak Boxes application.

1. Delete old RPM in ~/Downloads
2. Burger menu, Send File..., upload newly built rpm.
3. Install new RPM: `sudo rpm -i reverse-proxy-1.0.0-0.git*`
4. Reboot

```console
$ sudo systemctl status reverse-proxy-prep
○ reverse-proxy-prep.service
     Loaded: loaded (/usr/lib/systemd/system/reverse-proxy-prep.service; disabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: inactive (dead)

$ sudo systemctl enable reverse-proxy-prep
```

Then reboot the VM.

This should trigger start of `reverse-proxy-prep` service which will cause (user) `reverse-proxy` service to be created and started by Podman.

```console
$ sudo systemctl status reverse-proxy-prep
[sudo] password for test: 
● reverse-proxy-prep.service
     Loaded: loaded (/usr/lib/systemd/system/reverse-proxy-prep.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: active (exited) since Sun 2025-08-03 09:27:10 CEST; 24s ago
 Invocation: 4d40cd73695e4dd3a050cf70d158567b
    Process: 1074 ExecStartPre=sh -c id revproxy 2>/dev/null || useradd --uid 3010 revproxy (code=exited, status=0/SUCCESS)
    Process: 1177 ExecStart=loginctl enable-linger revproxy (code=exited, status=0/SUCCESS)
   Main PID: 1177 (code=exited, status=0/SUCCESS)
   Mem peak: 5.4M
        CPU: 69ms

Aug 03 09:27:09 fedora systemd[1]: Starting reverse-proxy-prep.service...
Aug 03 09:27:10 fedora useradd[1074]: new group: name=revproxy, GID=3010
Aug 03 09:27:10 fedora useradd[1074]: new user: name=revproxy, UID=3010, GID=3010, home=/home/revproxy, shell=/bin/bash, from=none
Aug 03 09:27:10 fedora sh[1074]: Creating mailbox file: File exists
Aug 03 09:27:10 fedora systemd[1]: Finished reverse-proxy-prep.service.
```

The user process should be running after restart:

```console
$ sudo systemctl --user -M revproxy@ status reverse-proxy
× reverse-proxy.service
     Loaded: loaded (/etc/containers/systemd/users/3010/reverse-proxy.container; generated)
    Drop-In: /usr/lib/systemd/user/service.d
             └─10-timeout-abort.conf
     Active: failed (Result: exit-code) since Sun 2025-08-17 09:14:14 CEST; 2min 39s ago
   Duration: 477ms
 Invocation: 51567d56247d4c08a40e5ee7fbd3aba1
    Process: 2281 ExecStart=/usr/bin/podman --log-level=warn run --name reverse-proxy --cidfile=/run/user/3010/reverse-proxy.cid --replace --rm --cgroups=split --sdnotify=conmon -d -v /usr/share/mada/reverse-proxy/nginx.conf:/etc/nginx/conf.d/default.conf:ro --publish 8080:80 --env TZ=Europe/Copenhagen --group-add=keep-groups --cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE --cidfile=/var/run/user/3010/reverse-proxy.cid docker.io/library/nginx@sha256:d83c0138ea82c9f05c4378a5001e0c71256b647603c10c186bd7697a4db722d3 (code=exited, status=1/FAILURE)
    Process: 2316 ExecStopPost=/usr/bin/podman --log-level=warn rm -v -f -i --cidfile=/run/user/3010/reverse-proxy.cid (code=exited, status=0/SUCCESS)
   Main PID: 2281 (code=exited, status=1/FAILURE)
   Mem peak: 195.7M
        CPU: 4.856s
```

**Debugging Container**

```console
