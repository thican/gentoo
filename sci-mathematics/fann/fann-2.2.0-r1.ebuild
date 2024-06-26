# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_P=FANN-${PV}-Source
inherit cmake

DESCRIPTION="Fast Artificial Neural Network Library"
HOMEPAGE="http://leenissen.dk/fann/wp/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${MY_P}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="examples"

RDEPEND=""
BDEPEND="app-arch/unzip"

S="${WORKDIR}/${MY_P}"

PATCHES=( "${FILESDIR}/${P}-examples.patch" )

src_test() {
	cd examples || die
	emake CFLAGS="${CFLAGS} -I../src/include -L${BUILD_DIR}/src"
	LD_LIBRARY_PATH="${BUILD_DIR}/src" emake runtest
	emake clean
}

src_install() {
	cmake_src_install
	if use examples; then
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
