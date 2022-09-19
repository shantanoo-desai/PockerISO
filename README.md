# PockerISO

Use Hashicorp Packer with Docker to build Bootable Image using Containers.

This repository tries its best to replicate [Ivan Velichko's @iximiuz docker-to-linux][1] repo
but using a single Packer Template which can be configured for different Distribution flavors.

 Result

| Distribution Name | Platform | Working | 
|:-----------------:|:--------:|:-------:|
| __Debian Bullseye__ <br> __Debian Bookworm__ |`linux/amd64` | :heavy_check_mark: |
| __Ubuntu 20.04 (Focal Fossa)__ <br> __Ubuntu 22.04 (Jammy Jellyfish)__ |`linux/amd64` | :heavy_check_mark: |
| __Alpine 3.16__  | `linux/amd64` | :heavy_check_mark: |


## Usage

Requirements:

- GNU Make (>=4.3)
- Docker (>=20.10.17)
- Hashicorp Packer (>=1.8.3)

### Initialize Packer

Initially download the Docker plugin for Hashicorp Packer using:

```
make init
```

### Ubuntu / Debian Images

```
make ubuntu
```
will build an ubuntu based bootable image

```
make debian
```

will build a debian based bootable image

### Alpine Images

```
make alpine

```
will build an alpine based bootable image

### Clean Up

```
make clean
```
removes all generated artifacts

## How does it work?

1. Bring up the respective container, install a compatible kernel and `systemd` in it (for Debian, Ubuntu) and `openrc` for Alpine.

2. Let Packer export the container's filesystem from Step 1 to a tarball. The tarball will be made
  available in the root directory of this repository as `{distribution}.tar` e.g. `ubuntu.tar`, `debian.tar`, `alpine.tar`

3. Unpack the filesystem tarball in a directory namely `{distribution}.dir`. This is mainly because Packer + Docker
  will often fail when trying to extract the tarball within the container. It will be easier to just copy the extracted
  content to the respective mount point in the container
4. the bash script in `scripts` directory takes the responsibility for creating a bootable image which will be available
  in the root directory of the repo as `{distribution}.img` and `{distribution}.qcow2`

## Emulating Results with QEMU

For `amd64` images, the final `.img` file will be created with `root` ownership, which will require `sudo` privileges

```
sudo qemu-system-x86_64 -m 4096 -smp 4 -drive file={distribution}.img,index=0,media=disk,format=raw 
```

here `{distribution}` will be either `ubuntu`, `debian`, `alpine`.

## Credits / Resources

- [Ivan Velichko's Blog Post][2]
- [Packer Docker Builder Documentation][3]

[1]: https://github.com/iximiuz/docker-to-linux
[2]: https://iximiuz.com/en/posts/from-docker-container-to-bootable-linux-disk-image/
[3]: https://www.packer.io/plugins/builders/docker
