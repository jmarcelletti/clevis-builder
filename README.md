clevis-builder is a quick Dockerfile I threw together to build a new clevis deb package based on clevis v12 which supports initramfs. In this journey I ran into some issues and have provided a workaround here. I hope to have these patches accepted upstream so I do not have to maintain this. For now I will continue to maintain this so that I can get clevis working for Ubuntu 18.04 and Ubuntu 20.04.

I hope to outline these issues more specifically below when I find time as well.

# Quickstart

## Build needed versions

tested on 18.04/20.04 so far, 16.04 will not work
```
./build.sh 18.04
./build.sh 20.04
```

After copying this debian package to the proper machine, simply install it.
```
dpkg -i clevis_12.0-0_amd64.deb

# Errors above for dependencies can be resolved by:
apt-get install -f -y
```

## Bind to something

In my case I am using tang, so here is a sample command.
```
# Your device/tang should vary please don't random copy/paste
clevis luks bind -d /dev/sda3 tang '{"url":"http://192.168.57.130"}'
```

## Update the initramfs and test
```
update-initramfs -k all -c

# likely not needed, but no harm.
update-grub

# reboot when ready..
```

