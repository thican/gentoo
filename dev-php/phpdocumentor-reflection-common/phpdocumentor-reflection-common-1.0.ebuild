# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="ReflectionCommon"
MY_VENDOR="phpDocumentor"

DESCRIPTION="Common reflection classes used by phpdocumentor to reflect the code structure"
HOMEPAGE="https://www.phpdoc.org"
SRC_URI="https://github.com/${MY_VENDOR}/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm ~hppa ppc64 ~s390 sparc x86"
IUSE=""

S="${WORKDIR}/${MY_PN}-${PV}"

RDEPEND="dev-php/fedora-autoloader
	>=dev-lang/php-5.6:*"

src_install() {
	insinto /usr/share/php/${MY_VENDOR}/${MY_PN}
	doins -r src/*
	doins "${FILESDIR}/autoload.php"
}
