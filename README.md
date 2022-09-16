# PockerISO

Use Hashicorp Packer with Docker to build Bootable Image using Containers.

This repository tries its best to replicate [Ivan Velichko's @iximiuz docker-to-linux][1] repo
but using a single Packer Template which can be configured for different Distribution flavors.

 Result

| Distribution Name | Platform | Working | 
|:-----------------:|:--------:|:-------:|
| __Debian Bullseye__ |`linux/amd64` | :heavy_check_mark: |


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

### Ubuntu 20.04 Image

```
make ubuntu
```
will build an ubuntu based bootable image

```
make debian
```

will build a debian based bootable image

### Clean Up

```
make clean
```
removes all generated artifacts

## How does it work?

1. Bring up the respective container, install a compatible kernel and `systemd` in it.

2. Let Packer export the container's filesystem from Step 1 to a tarball. The tarball will be made
  available in the root directory of this repository as `{distribution}.tar` e.g. `ubuntu.tar`, `debian.tar`

3. Unpack the filesystem tarball in a directory namely `{distribution}.dir`. This is mainly because Packer + Docker
  will often fail when trying to extract the tarball within the container. It will be easier to just copy the extracted
  content to the respective mount point in the container
4. the bash script in `scripts` directory takes the responsibility for creating a bootable image which will be available
  in the root directory of the repo as `{distribution}.img` and `{distribution}.qcow2`

## On-Going Trials for Image Creation

| Distribution Name | Distribution Version |
|:------------------|:---------------------|
| __Debian__        | ~~`bullseye`~~<br/> `bookworm`|
| __Ubuntu__        | `focal`<br/>`jammy`  |

## Credits / Resources

- [Ivan Velichko's Blog Post][2]
- [Packer Docker Builder Documentation][3]

[1]: https://github.com/iximiuz/docker-to-linux
[2]: https://iximiuz.com/en/posts/from-docker-container-to-bootable-linux-disk-image/
[3]: https://www.packer.io/plugins/builders/docker
