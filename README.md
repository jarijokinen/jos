# Jari's Operating System (JOS)

JOS is a simple operating system for x86-64 that I've written as a hobby.

## Run with QEMU

```
su -c apt-get install qemu-system-x86 qemu-system-gui qemu-utils
git clone https://github.com/jarijokinen/jos.git
cd jos
make run
```

## Create a bootable USB device

```
git clone https://github.com/jarijokinen/jos.git
cd jos
make jos.img
dd if=jos.img of=/dev/sdXX
```

## License

MIT License. Copyright (c) 2018 [Jari Jokinen](https://jarijokinen.com). See
[LICENSE](https://github.com/jarijokinen/jos/blob/master/LICENSE.txt) for
further details.
