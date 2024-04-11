.. |---| unicode:: U+02014 .. em dash

****
ELBE
****

ELBE |---| Embedded Linux Build System.
Использует пакетную базу Debian.

.. contents::

==========
Подготовка
==========

Установка
---------

Самый простой способ установки ELBE |---| из официального репозитория для Debian.

Если текущая система |---| не Debian, то проще всего воспользоваться Docker-образом::

   $ docker run -it debian:latest
   # apt update
   # apt install -y neovim # какой-нибудь редактор

Затем нужно включить репозиторий::

   # apt install -y elbe-archive-keyring
   # echo "deb [signed-by=/usr/share/keyrings/elbe-archive-keyring.gpg] http://debian.linutronix.de/elbe buster main" >>/etc/apt/sources.list

Далее, установить ELBE::

   # apt update
   # apt install elbe

Инициализация окружения
-----------------------

Для начала нужно инициализировать виртуальную машину,
в которой будет проходить сборка |---| в терминологии ELBE это ``initvm``::

   # mkdir elbe && cd elbe
   # elbe initvm create

==========
Разработка
==========

Первый образ
------------

В созданную ранее виртуальную машину **загружаются (submit) XML-файлы**,
описывающие образы, которые необходимо собрать.

В каталог ``/usr/share/doc/elbe/examples`` был установлен ряд примеров таких файлов.

К нашим задачам близок ``arm64-qemu-virt.xml`` со следующим содержимым:

.. code:: xml

   <!--
   SPDX-License-Identifier: 0BSD
   SPDX-FileCopyrightText: Linutronix GmbH
   -->
   <ns0:RootFileSystem xmlns:ns0="https://www.linutronix.de/projects/Elbe" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" created="2009-05-20T08:50:56" revision="6" xsi:schemaLocation="https://www.linutronix.de/projects/Elbe dbsfed.xsd">
   	<project>
   		<name>aarch64</name>
   		<version>1.0</version>
   		<description>
   			use the following call to boot the image in qemu:
   			$ tar xf sdcard.qcow2.tar.xz
   			$ rm sdcard.qcow2.tar.xz
   			$ qemu-system-aarch64 \
   					-machine virt -cpu cortex-a57 -machine type=virt -nographic \
   					-smp 1 -m 1024 \
   					-netdev user,id=unet -device virtio-net-device,netdev=unet \
   					-redir tcp:2022::22 -redir tcp:2021::21 -redir tcp:2345::2345 \
   					-kernel vmlinuz \
   					-append "console=ttyAMA0 root=/dev/vda2" \
   					sdcard.qcow2
   
   			currently an own kernel is needed, but this shouldn't be necessary,
   			if we found how to use the one stored in mmcblk0p1
   		</description>
   		<buildtype>aarch64</buildtype>
   		<mirror>
   			<primary_host>ftp.de.debian.org</primary_host>
   			<primary_path>/debian</primary_path>
   			<primary_proto>http</primary_proto>
   		</mirror>
   		<suite>buster</suite>
   	</project>
   	<target>
   		<hostname>lx64</hostname>
   		<domain>linutronix.de</domain>
   		<passwd>foo</passwd>
   		<console>ttyAMA0,115200</console>
   		<images>
   			<msdoshd>
   				<name>sdcard.img</name>
   				<size>1500MiB</size>
   					<partition>
   						<size>50MiB</size>
   						<label>boot</label>
   						<bootable />
   					</partition>
   					<partition>
   						<size>remain</size>
   						<label>rfs</label>
   					</partition>
   			</msdoshd>
   		</images>
   		<fstab>
   			<bylabel>
   				<label>boot</label>
   				<mountpoint>/boot</mountpoint>
   				<fs>
   					<type>vfat</type>
   				</fs>
   			</bylabel>
   			<bylabel>
   				<label>rfs</label>
   				<mountpoint>/</mountpoint>
   				<fs>
   					<type>ext2</type>
   					<fs-finetuning>
   						<device-command>tune2fs -i 0 {device}</device-command>
   					</fs-finetuning>
   				</fs>
   			</bylabel>
   		</fstab>
   		<install-recommends />
   		<finetuning>
   			<rm>/var/cache/apt/archives/*.deb</rm>
   		</finetuning>
   		<pkg-list>
   			<pkg>linux-image-arm64</pkg>
   			<pkg>openssh-server</pkg>
   			<pkg>less</pkg>
   			<pkg>bash</pkg>
   			<pkg>vim-nox</pkg>
   			<pkg>wget</pkg>
   			<pkg>ntpdate</pkg>
   			<pkg>busybox</pkg>
   		</pkg-list>
   		<project-finetuning>
   			<losetup img="sdcard.img">
   				<!-- globs work, but must make sure, that only a single file is matched -->
   				<copy_from_partition part="1" artifact="vmlinuz">/vmlinuz-4.19.0-*-arm64</copy_from_partition>
   			</losetup>
   			<img_convert fmt="qcow2" dst="sdcard.qcow2">sdcard.img</img_convert>
   			<set_packer packer="tarxz">sdcard.qcow2</set_packer>
   		</project-finetuning>
   	</target>
   </ns0:RootFileSystem>
