#     PockerISO: Use Packer + Docker to make bootable images
#     Copyright (C) 2022  Shantanoo 'Shan' Desai <sdes.softdev@gmail.com>

#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.

#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.


packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source = "github.com/hashicorp/docker"
    }
  }
}

variable distro {
    type = string
}

variable distro_version {
    type = string
}

variable distro_platform {
    type = string
    default = "linux/amd64"
}

variable distro_kernel {
    type = string
}

locals {
    distro_docker_image = "${var.distro}:${var.distro_version}"
}

# This Source will only be used to create a Filesystem from the Docker Container
source "docker" "filesystem-container" {
    image = "${local.distro_docker_image}"
    pull = false # save bandwidth and avoid multiple pulls to same image
    platform = "${var.distro_platform}"
    export_path = "./${var.distro}.tar"
}

# This source will be use to create a Bootable Disk Image from the Generated Filesystem
source "docker" "partition-container" {
    image = "debian:bullseye"
    pull = false
    platform = "${var.distro_platform}"
    discard = true
    cap_add = [ "SYS_ADMIN" ]
    privileged = true
    volumes = {
        "${path.cwd}": "/os"
    }
}

build {
    # Install the Respective Kernel and SystemD
    name = "gen-fs-tarball"
    sources = [ "source.docker.filesystem-container" ]
    provisioner "shell" {
        inline = [
            "apk update",
            "apk add ${var.distro_kernel}",
            "apk add openrc",
            "echo \"root:root\" | chpasswd"
        ]
    }
}

build {
    # generate a bootable disk image
    name = "gen-boot-img"
    sources = [ "source.docker.partition-container" ]
    provisioner "shell" {
        environment_vars = [
            "DISTR=${var.distro}"
        ]
        scripts = [
            "./scripts/create-image.sh"
        ]
    }
}
