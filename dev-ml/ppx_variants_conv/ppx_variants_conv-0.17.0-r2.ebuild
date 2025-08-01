# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune

DESCRIPTION="Generation of accessor and iteration functions for ocaml variant types"
HOMEPAGE="https://github.com/janestreet/ppx_variants_conv"
SRC_URI="https://github.com/janestreet/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm64 ~ppc ~ppc64 ~riscv"
IUSE="+ocamlopt"

# Jane Street Minor
JSM=$(ver_cut 1-2)

RDEPEND="
	>=dev-lang/ocaml-5
	=dev-ml/base-${JSM}*:=[ocamlopt?]
	=dev-ml/variantslib-${JSM}*:=[ocamlopt?]
	>=dev-ml/ppxlib-0.32.1:=[ocamlopt?]
	<dev-ml/ppxlib-0.36.0
"
DEPEND="${RDEPEND}"
BDEPEND=">=dev-ml/dune-3.11"
