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


TEMPLATE_FILE=template.pkr.hcl

.PHONY:
debian: debian.img

.PHONY:
ubuntu: ubuntu.img

.PHONY:
init:
	packer init -upgrade ${TEMPLATE_FILE}

%.tar:
	@echo "Packer Build: Generate the Container Filesystem Tarball"
	packer build -var-file=./vars/$*.pkrvars.hcl -only="gen-fs-tarball.*" ${TEMPLATE_FILE}

%.dir: %.tar
	@echo "Extracting tarball to a directory.."
	mkdir $*.dir
	tar -vxf $*.tar -C $*.dir

%.img: %.dir
	packer build -var-file=./vars/$*.pkrvars.hcl -only="gen-boot-img.*" ${TEMPLATE_FILE}

.PHONY:
clean:
	rm -rf mnt ubuntu.* debian.*
