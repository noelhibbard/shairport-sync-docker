# Introduction
This guide assumes you have solid knowledge of Linux, shairport-sync, PulseAudio, Docker and Docker Compose. If you are solid on these things, this guide should be easy to follow. This guide also assumes your Linux server doesn’t have a desktop environment because this guide will have you disable the usermode PulseAudio service which would probably break a desktop environment. I am personally running Debian but Ubuntu should work with these instructions. Other distros may also work with minimal deviation from these instructions.

## Clone this repo somewhere on your server
```bash
git clone https://github.com/noelhibbard/sharport-sync-docker.git
```

## Install Docker and Docker Compose Pluggin on host
- Docker install instructions: https://docs.docker.com/engine/install/debian/

## Install / Configure PulseAudio on host
- Install Packages
    ```bash
    apt update && apt install -y pulseaudio pulseaudio-utils alsa-utils
    ```
- Disable usermode systemd service
    ```bash
    sudo systemctl --global disable pulseaudio.service pulseaudio.socket
    ```
- Install system wide PulseAudio systemd service
    ```bash
    sudo usermod -d /var/run/pulse pulse
    sudo adduser root audio
    sudo adduser root pulse-access
    sudo systemctl --system enable $PWD/pulseaudio.service --now
    ```
## Configure PulseAudio to use a UNIX socket
Empty out the entire ```/etc/pulse/system.pa``` and add this single line:
```
echo "load-module module-native-protocol-unix auth-anonymous=1" > /etc/pulse/system.pa
```

## Add PulseAudio sinks that point to ALSA outputs
Add a line to ```/etc/pulse/system.pa``` for each ALSA output you want available in in Pulse. For example:
```
echo "load-module module-alsa-sink device=<device> sink_name=<sink_name>" >> /etc/pulse/system.pa
```
Note: ```device``` is the ALSA output device you want to make available in PulseAudio (Example: ```hw:0```). ```sink-name``` is the name of the sink. What ever you use here is what you will use in shairport-sync.conf for the pa sink.

Restart PulseAudio to reload config
```bash
sudo systemctl restart pulseaudio
```

## Configure host network in docker-compose.yaml template
The docker containers will be placed on your host network. Before you can do that you have to supply the physical network interface, subnet and gateway for your host network.
- set interface here: ```networks.spsnet.driver_opts.parent``` (Example: ```eth0```)
- set subnet here: ```networks.spsnet.ipam.config.subnet``` (Example: ```192.168.1.0/24```)
- set gateway here: ```networks.spsnet.ipam.config.gateway``` (Example: ```192.168.1.254```)

## Configure SPS instances within docker-compose.yaml
A single docker-compose.yaml will contain the configureation for all your SPS docker containers. My example has two instances. One named Instance1 with the IP 192.168.1.101 and the other named Instance2 with the IP 192.168.1.102. Edit these how ever fits your environment. Also notice the volume entry that maps your shairport-sync.conf into the container. Make sure you also edit the name and PulseAudio sink wihin your shairport-sync.conf files.

## Start the containers
```bash
docker compose up -d
```

## Stop the containers
```bash
docker compose stop
```

## Restart the containers
```bash
docker compose restart
```

## Monitor shairport-sync output
```bash
docker compose logs -f
```

## Update your containers to the latest version of NQPTP and shairport-sync.
```bash
docker compose pull
docker compose up -d
```
