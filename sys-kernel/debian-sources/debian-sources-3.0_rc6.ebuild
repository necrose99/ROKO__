# Copyright 2011 Funtoo Technologies (Rosen Alexandrow - sandikata@yandex.ru)
# Distributed under the terms of the GNU General Public License v2

EAPI=2
ETYPE="sources"

KV_DEB=
KV_FULL=${PVR}
EXTRAVERSION=${KV_DEB}

inherit kernel-2
detect_version

KEYWORDS="~amd64 ~x86"
DESCRIPTION="Debian Sources - with optional OpenVZ support"
HOMEPAGE="http://www.debian.org"
SRC_URI="
	 http://ftp.bg.debian.org/debian/pool/main/l/linux-2.6/linux-2.6_3.0.0~rc6.orig.tar.gz
	 http://ftp.bg.debian.org/debian/pool/main/l/linux-2.6/linux-2.6_3.0.0~rc6-1~experimental.1.diff.gz"
UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${FILESDIR}/debian-sources-2.6.38.3-bridgemac.patch"
IUSE="openvz"
K_EXTRAEINFO=""

src_unpack() {
	cd ${WORKDIR}
	unpack linux-2.6_3.0.0~rc6.orig.tar.gz
	cat ${DISTDIR}/linux-2.6_3.0.0~rc6-1~experimental.1.diff.gz | gzip -d | patch -p1 || die
	mv linux-* linux-${KV_FULL} || die
	mv debian linux-${KV_FULL}/ || die
	cd ${S}
	sed -i \
		-e 's/^sys.path.append.*$/sys.path.append(".\/debian\/lib\/python")/' \
		-e 's/^_default_home =.*$/_default_home = ".\/debian\/patches"/' \
		debian/bin/patch.apply || die
	python2 debian/bin/patch.apply $KV_DEB || die
	if use openvz
	then
		python2 debian/bin/patch.apply -a $ARCH -f openvz || die
	fi
	unpack_set_extraversion
}

src_install() {
	kernel-2_src_install
	exeinto /usr/src/linux-${KV_FULL}
	doexe ${FILESDIR}/config-extract
	doexe ${FILESDIR}/.config
}

pkg_postinst() {
	kernel-2_pkg_postinst
}
