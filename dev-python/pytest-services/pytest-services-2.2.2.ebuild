# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} pypy3_11 )

inherit distutils-r1

DESCRIPTION="Collection of fixtures and utility functions to run service processes for pytest"
HOMEPAGE="
	https://github.com/pytest-dev/pytest-services/
	https://pypi.org/project/pytest-services/
"
SRC_URI="
	https://github.com/pytest-dev/pytest-services/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"

RDEPEND="
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/zc-lockfile[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	test? (
		dev-python/pylibmc[${PYTHON_USEDEP}]
		x11-base/xorg-server[xvfb]
		net-misc/memcached
		!!dev-python/pytest-salt
	)
"

EPYTEST_PLUGINS=( "${PN}" )
distutils_enable_tests pytest

PATCHES=(
	"${FILESDIR}/pytest-services-2.0.1-no-mysql.patch"
	"${FILESDIR}/pytest-services-2.0.1-lockdir.patch"
)

export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
