# Copyright 2019-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake-multilib

DESCRIPTION="Heavily optimized DEFLATE/zlib/gzip (de)compression"
HOMEPAGE="https://github.com/ebiggers/libdeflate"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ebiggers/libdeflate.git"
else
	SRC_URI="
		https://github.com/ebiggers/libdeflate/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/ebiggers/libdeflate/commit/2a3762cf736aff9aa5dda329fdec3c08a816eb9b.patch -> ${P}-gcc-16.1.patch
		https://github.com/ebiggers/libdeflate/commit/6bb493615b0ef35c98fc4aa4ec04f448788db6a5.patch -> ${P}-gcc-16.2.patch
	"
	KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~mips ppc ppc64 ~riscv ~s390 ~sparc x86"
fi

LICENSE="MIT"
SLOT="0"
# the zlib USE-flag enables support for zlib
# the test USE-flag programs depend on sys-libs/zlib for comparison tests
IUSE="+utils test"

RESTRICT="
	!test? ( test )
"

DEPEND="
	test? ( sys-libs/zlib[${MULTILIB_USEDEP}] )
"

PATCHES=(
	"${FILESDIR}/${PN}-1.19-make-gzip-tests-conditional.patch"
	"${DISTDIR}/${P}-gcc-16.1.patch"
	"${DISTDIR}/${P}-gcc-16.2.patch"
)

src_configure() {
	local mycmakeargs=(
		-DLIBDEFLATE_BUILD_SHARED_LIB="yes"
		-DLIBDEFLATE_BUILD_STATIC_LIB="no"
		-DLIBDEFLATE_USE_SHARED_LIB="yes"

		-DLIBDEFLATE_COMPRESSION_SUPPORT="yes"
		-DLIBDEFLATE_DECOMPRESSION_SUPPORT="yes"

		-DLIBDEFLATE_BUILD_GZIP="$(usex utils)"
		-DLIBDEFLATE_GZIP_SUPPORT="yes"

		-DLIBDEFLATE_ZLIB_SUPPORT="yes"

		-DLIBDEFLATE_BUILD_TESTS="$(usex test)"
	)

	cmake-multilib_src_configure
}
