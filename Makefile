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


DEBIAN_TEMPLATE_FILE=templates/debian-template.pkr.hcl
ALPINE_TEMPLATE_FILE=templates/alpine-template.pkr.hcl

.PHONY:
debian: debian.img

.PHONY:
ubuntu: ubuntu.img

.PHONY:
alpine: alpine.img

.PHONY:
init:
	packer init -upgrade ${TEMPLATE_FILE}

%.tar:
	@echo "Packer Build: Generate the Container Filesystem Tarball"
ifneq ($(filter $(MAKECMDGOALS),ubuntu debian),)
	packer build -var-file=./vars/$*.pkrvars.hcl -only="gen-fs-tarball.*" ${DEBIAN_TEMPLATE_FILE}
else
	packer build -var-file=./vars/$*.pkrvars.hcl -only="gen-fs-tarball.*" ${ALPINE_TEMPLATE_FILE}
endif

%.dir: %.tar
	@echo "Extracting tarball to a directory.."
	mkdir $*.dir
	tar -vxf $*.tar -C $*.dir

%.img: %.dir
ifneq ($(filter $(MAKECMDGOALS),ubuntu debian),)
	packer build -var-file=./vars/$*.pkrvars.hcl -only="gen-boot-img.*" ${DEBIAN_TEMPLATE_FILE}
else
	packer build -var-file=./vars/$*.pkrvars.hcl -only="gen-boot-img.*" ${ALPINE_TEMPLATE_FILE}
endif

.PHONY:
clean:
	rm -rf mnt ubuntu.* debian.* alpine.*
