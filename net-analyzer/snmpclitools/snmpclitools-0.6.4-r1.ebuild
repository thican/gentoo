# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..11} )
inherit distutils-r1

DESCRIPTION="Pure-Python SNMP management tools"
HOMEPAGE="https://github.com/etingof/snmpclitools"
SRC_URI="https://github.com/etingof/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/pysnmp-4.2.2[${PYTHON_USEDEP}]
	dev-python/pysnmp-mibs[${PYTHON_USEDEP}]
"
