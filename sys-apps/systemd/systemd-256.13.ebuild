# Copyright 2011-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )

# Avoid QA warnings
TMPFILES_OPTIONAL=1
UDEV_OPTIONAL=1

QA_PKGCONFIG_VERSION=$(ver_cut 1)

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/systemd/systemd.git"
	inherit git-r3
else
	MY_PV=${PV/_/-}
	MY_P=${PN}-${MY_PV}
	S=${WORKDIR}/${MY_P}
	SRC_URI="https://github.com/systemd/${PN}/archive/refs/tags/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

	if [[ ${PV} != *rc* ]] ; then
		KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
	fi
fi

inherit bash-completion-r1 linux-info meson-multilib optfeature pam python-single-r1
inherit secureboot systemd toolchain-funcs udev

DESCRIPTION="System and service manager for Linux"
HOMEPAGE="https://systemd.io/"

LICENSE="GPL-2 LGPL-2.1 MIT public-domain"
SLOT="0/2"
IUSE="
	acl apparmor audit boot bpf cgroup-hybrid cryptsetup curl +dns-over-tls elfutils
	fido2 +gcrypt gnutls homed http idn importd iptables +kernel-install +kmod
	+lz4 lzma +openssl pam pcre pkcs11 policykit pwquality qrcode
	+resolvconf +seccomp selinux split-usr +sysv-utils test tpm ukify vanilla xkb +zstd
"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	dns-over-tls? ( || ( gnutls openssl ) )
	fido2? ( cryptsetup openssl )
	homed? ( cryptsetup pam openssl )
	importd? ( curl lzma || ( gcrypt openssl ) )
	pwquality? ( homed )
	boot? ( kernel-install )
	ukify? ( boot )
"
RESTRICT="!test? ( test )"

MINKV="4.15"

COMMON_DEPEND="
	>=sys-apps/util-linux-2.32:0=[${MULTILIB_USEDEP}]
	sys-libs/libcap:0=[${MULTILIB_USEDEP}]
	virtual/libcrypt:=[${MULTILIB_USEDEP}]
	acl? ( sys-apps/acl:0= )
	apparmor? ( >=sys-libs/libapparmor-2.13:0= )
	audit? ( >=sys-process/audit-2:0= )
	bpf? ( >=dev-libs/libbpf-1.4.0:0= )
	cryptsetup? ( >=sys-fs/cryptsetup-2.0.1:0= )
	curl? ( >=net-misc/curl-7.32.0:0= )
	elfutils? ( >=dev-libs/elfutils-0.158:0= )
	fido2? ( dev-libs/libfido2:0= )
	gcrypt? ( >=dev-libs/libgcrypt-1.4.5:0=[${MULTILIB_USEDEP}] )
	gnutls? ( >=net-libs/gnutls-3.6.0:0= )
	http? ( >=net-libs/libmicrohttpd-0.9.33:0=[epoll(+)] )
	idn? ( net-dns/libidn2:= )
	importd? (
		app-arch/bzip2:0=
		sys-libs/zlib:0=
	)
	kmod? ( >=sys-apps/kmod-15:0= )
	lz4? ( >=app-arch/lz4-0_p131:0=[${MULTILIB_USEDEP}] )
	lzma? ( >=app-arch/xz-utils-5.0.5-r1:0=[${MULTILIB_USEDEP}] )
	iptables? ( net-firewall/iptables:0= )
	openssl? ( >=dev-libs/openssl-1.1.0:0= )
	pam? ( sys-libs/pam:=[${MULTILIB_USEDEP}] )
	pkcs11? ( >=app-crypt/p11-kit-0.23.3:0= )
	pcre? ( dev-libs/libpcre2 )
	pwquality? ( >=dev-libs/libpwquality-1.4.1:0= )
	qrcode? ( >=media-gfx/qrencode-3:0= )
	seccomp? ( >=sys-libs/libseccomp-2.3.3:0= )
	selinux? ( >=sys-libs/libselinux-2.1.9:0= )
	tpm? ( app-crypt/tpm2-tss:0= )
	xkb? ( >=x11-libs/libxkbcommon-0.4.1:0= )
	zstd? ( >=app-arch/zstd-1.4.0:0=[${MULTILIB_USEDEP}] )
"

# Newer linux-headers needed by ia64, bug #480218
DEPEND="${COMMON_DEPEND}
	>=sys-kernel/linux-headers-${MINKV}
"

PEFILE_DEPEND='dev-python/pefile[${PYTHON_USEDEP}]'

# baselayout-2.2 has /run
RDEPEND="${COMMON_DEPEND}
	>=acct-group/adm-0-r1
	>=acct-group/wheel-0-r1
	>=acct-group/kmem-0-r1
	>=acct-group/tty-0-r1
	>=acct-group/utmp-0-r1
	>=acct-group/audio-0-r1
	>=acct-group/cdrom-0-r1
	>=acct-group/dialout-0-r1
	>=acct-group/disk-0-r1
	>=acct-group/input-0-r1
	>=acct-group/kvm-0-r1
	>=acct-group/lp-0-r1
	>=acct-group/render-0-r1
	acct-group/sgx
	>=acct-group/tape-0-r1
	acct-group/users
	>=acct-group/video-0-r1
	>=acct-group/systemd-journal-0-r1
	>=acct-user/root-0-r1
	acct-user/nobody
	>=acct-user/systemd-journal-remote-0-r1
	>=acct-user/systemd-coredump-0-r1
	>=acct-user/systemd-network-0-r1
	acct-user/systemd-oom
	>=acct-user/systemd-resolve-0-r1
	>=acct-user/systemd-timesync-0-r1
	>=sys-apps/baselayout-2.2
	ukify? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep "${PEFILE_DEPEND}")
	)
	selinux? (
		sec-policy/selinux-base-policy[systemd]
		sec-policy/selinux-ntp
	)
	sysv-utils? (
		!sys-apps/openrc[sysv-utils(-)]
		!sys-apps/sysvinit
	)
	!sysv-utils? ( sys-apps/sysvinit )
	resolvconf? ( !net-dns/openresolv )
	!sys-auth/nss-myhostname
	!sys-fs/eudev
	!sys-fs/udev
"

# sys-apps/dbus: the daemon only (+ build-time lib dep for tests)
PDEPEND=">=sys-apps/dbus-1.9.8[systemd]
	>=sys-fs/udev-init-scripts-34
	policykit? ( sys-auth/polkit )
	!vanilla? ( sys-apps/gentoo-systemd-integration )"

BDEPEND="
	app-arch/xz-utils:0
	dev-util/gperf
	>=dev-build/meson-0.46
	>=sys-apps/coreutils-8.16
	sys-devel/gettext
	virtual/pkgconfig
	bpf? (
		>=dev-util/bpftool-7.0.0
		sys-devel/bpf-toolchain
	)
	test? (
		app-text/tree
		dev-lang/perl
		sys-apps/dbus
	)
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt:0
	${PYTHON_DEPS}
	$(python_gen_cond_dep "
		dev-python/jinja2[\${PYTHON_USEDEP}]
		dev-python/lxml[\${PYTHON_USEDEP}]
		boot? (
			>=dev-python/pyelftools-0.30[\${PYTHON_USEDEP}]
			test? ( ${PEFILE_DEPEND} )
		)
	")
"

QA_FLAGS_IGNORED="usr/lib/systemd/boot/efi/.*"
QA_EXECSTACK="usr/lib/systemd/boot/efi/*"

check_cgroup_layout() {
	# https://bugs.gentoo.org/935261
	[[ ${MERGE_TYPE} != buildonly ]] || return
	[[ -z ${ROOT} ]] || return
	[[ -e /sys/fs/cgroup/unified ]] || return
	grep -q 'SYSTEMD_CGROUP_ENABLE_LEGACY_FORCE=1' /proc/cmdline && return

	eerror "This system appears to be booted with the 'hybrid' cgroup layout."
	eerror "This layout obsolete and is disabled in systemd."

	if grep -qF 'systemd.unified_cgroup_hierarchy'; then
		eerror "Remove the systemd.unified_cgroup_hierarchy option"
		eerror "from the kernel command line and reboot."
		die "hybrid cgroup layout detected"
	fi
}

pkg_pretend() {
	if use split-usr; then
		eerror "Please complete the migration to merged-usr."
		eerror "https://wiki.gentoo.org/wiki/Merge-usr"
		die "systemd no longer supports split-usr"
	fi

	check_cgroup_layout

	if use cgroup-hybrid; then
		eerror "Disable the 'cgroup-hybrid' USE flag."
		eerror "Rebuild any initramfs images after rebuilding systemd."
		die "cgroup-hybrid is no longer supported"
	fi

	if [[ ${MERGE_TYPE} != buildonly ]]; then
		local CONFIG_CHECK="~BLK_DEV_BSG ~CGROUPS
			~CGROUP_BPF ~DEVTMPFS ~EPOLL ~FANOTIFY ~FHANDLE
			~INOTIFY_USER ~IPV6 ~NET ~NET_NS ~PROC_FS ~SIGNALFD ~SYSFS
			~TIMERFD ~TMPFS_XATTR ~UNIX ~USER_NS
			~CRYPTO_HMAC ~CRYPTO_SHA256 ~CRYPTO_USER_API_HASH
			~!GRKERNSEC_PROC ~!IDE ~!SYSFS_DEPRECATED
			~!SYSFS_DEPRECATED_V2"

		use acl && CONFIG_CHECK+=" ~TMPFS_POSIX_ACL"
		use bpf && CONFIG_CHECK+=" ~BPF ~BPF_SYSCALL ~BPF_LSM ~DEBUG_INFO_BTF"
		use seccomp && CONFIG_CHECK+=" ~SECCOMP ~SECCOMP_FILTER"

		if kernel_is -ge 5 10 20; then
			CONFIG_CHECK+=" ~KCMP"
		else
			CONFIG_CHECK+=" ~CHECKPOINT_RESTORE"
		fi

		if kernel_is -ge 4 18; then
			CONFIG_CHECK+=" ~AUTOFS_FS"
		else
			CONFIG_CHECK+=" ~AUTOFS4_FS"
		fi

		if linux_config_exists; then
			local uevent_helper_path=$(linux_chkconfig_string UEVENT_HELPER_PATH)
			if [[ -n ${uevent_helper_path} ]] && [[ ${uevent_helper_path} != '""' ]]; then
				ewarn "It's recommended to set an empty value to the following kernel config option:"
				ewarn "CONFIG_UEVENT_HELPER_PATH=${uevent_helper_path}"
			fi
			if linux_chkconfig_present X86; then
				CONFIG_CHECK+=" ~DMIID"
			fi
		fi

		if kernel_is -lt ${MINKV//./ }; then
			ewarn "Kernel version at least ${MINKV} required"
		fi

		check_extra_config
	fi
}

pkg_setup() {
	use boot && secureboot_pkg_setup
}

src_unpack() {
	default
	[[ ${PV} != 9999 ]] || git-r3_src_unpack
}

src_prepare() {
	local PATCHES=(
		"${FILESDIR}/systemd-test-process-util.patch"
		"${FILESDIR}/256-bpf-gcc.patch"
	)

	if ! use vanilla; then
		PATCHES+=(
			"${FILESDIR}/gentoo-journald-audit-r1.patch"
		)
	fi

	default
}

src_configure() {
	# Prevent conflicts with i686 cross toolchain, bug 559726
	tc-export AR CC NM OBJCOPY RANLIB

	python_setup

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local myconf=(
		--localstatedir="${EPREFIX}/var"
		# default is developer, bug 918671
		-Dmode=release
		-Dsupport-url="https://gentoo.org/support/"
		-Dpamlibdir="$(getpam_mod_dir)"
		# avoid bash-completion dep
		-Dbashcompletiondir="$(get_bashcompdir)"
		-Dsplit-bin=false
		# Disable compatibility with sysvinit
		-Dsysvinit-path=
		-Dsysvrcnd-path=
		# no deps
		-Dima=true
		# Match /etc/shells, bug 919749
		-Ddebug-shell="${EPREFIX}/bin/sh"
		-Ddefault-user-shell="${EPREFIX}/bin/bash"
		# Optional components/dependencies
		$(meson_native_use_feature acl)
		$(meson_native_use_feature apparmor)
		$(meson_native_use_feature audit)
		$(meson_native_use_feature boot bootloader)
		$(meson_native_use_feature bpf bpf-framework)
		-Dbpf-compiler=gcc
		$(meson_native_use_feature cryptsetup libcryptsetup)
		$(meson_native_use_feature curl libcurl)
		$(meson_native_use_bool dns-over-tls dns-over-tls)
		$(meson_native_use_feature elfutils)
		$(meson_native_use_feature fido2 libfido2)
		$(meson_feature gcrypt)
		$(meson_native_use_feature gnutls)
		$(meson_native_use_feature homed)
		$(meson_native_use_feature http microhttpd)
		$(meson_native_use_bool idn)
		$(meson_native_use_feature importd)
		$(meson_native_use_feature importd bzip2)
		$(meson_native_use_feature importd zlib)
		$(meson_native_use_bool kernel-install)
		$(meson_native_use_feature kmod)
		$(meson_feature lz4)
		$(meson_feature lzma xz)
		$(meson_use test tests)
		$(meson_feature zstd)
		$(meson_native_use_feature iptables libiptc)
		$(meson_native_use_feature openssl)
		$(meson_feature pam)
		$(meson_native_use_feature pkcs11 p11kit)
		$(meson_native_use_feature pcre pcre2)
		$(meson_native_use_feature policykit polkit)
		$(meson_native_use_feature pwquality)
		$(meson_native_use_feature qrcode qrencode)
		$(meson_native_use_feature seccomp)
		$(meson_native_use_feature selinux)
		$(meson_native_use_feature tpm tpm2)
		$(meson_native_use_feature test dbus)
		$(meson_native_use_feature ukify)
		$(meson_native_use_feature xkb xkbcommon)
		-Dntp-servers="0.gentoo.pool.ntp.org 1.gentoo.pool.ntp.org 2.gentoo.pool.ntp.org 3.gentoo.pool.ntp.org"
		# Breaks screen, tmux, etc.
		-Ddefault-kill-user-processes=false
		-Dcreate-log-dirs=false

		# multilib options
		$(meson_native_true backlight)
		$(meson_native_true binfmt)
		$(meson_native_true coredump)
		$(meson_native_true environment-d)
		$(meson_native_true firstboot)
		$(meson_native_true hibernate)
		$(meson_native_true hostnamed)
		$(meson_native_true ldconfig)
		$(meson_native_true localed)
		$(meson_native_enabled man)
		$(meson_native_true networkd)
		$(meson_native_true quotacheck)
		$(meson_native_true randomseed)
		$(meson_native_true rfkill)
		$(meson_native_true sysusers)
		$(meson_native_true timedated)
		$(meson_native_true timesyncd)
		$(meson_native_true tmpfiles)
		$(meson_native_true vconsole)
	)

	case $(tc-arch) in
		amd64|arm|arm64|ppc|ppc64|s390|x86)
			# src/vmspawn/vmspawn-util.h: QEMU_MACHINE_TYPE
			myconf+=( $(meson_native_enabled vmspawn) ) ;;
		*)
			myconf+=( -Dvmspawn=disabled ) ;;
	esac

	meson_src_configure "${myconf[@]}"
}

multilib_src_test() {
	(
		unset DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR
		export COLUMNS=80
		addpredict /dev
		addpredict /proc
		addpredict /run
		addpredict /sys/fs/cgroup
		meson_src_test --timeout-multiplier=10
	) || die
}

multilib_src_install_all() {
	# meson doesn't know about docdir
	mv "${ED}"/usr/share/doc/{systemd,${PF}} || die

	einstalldocs
	dodoc "${FILESDIR}"/nsswitch.conf

	insinto /usr/lib/tmpfiles.d
	doins "${FILESDIR}"/legacy.conf

	if ! use resolvconf; then
		rm -f "${ED}"/usr/bin/resolvconf || die
	fi

	if ! use sysv-utils; then
		rm "${ED}"/usr/bin/{halt,init,poweroff,reboot,shutdown} || die
		rm "${ED}"/usr/share/man/man1/init.1 || die
		rm "${ED}"/usr/share/man/man8/{halt,poweroff,reboot,shutdown}.8 || die
	fi

	# https://bugs.gentoo.org/761763
	rm -r "${ED}"/usr/lib/sysusers.d || die

	# Preserve empty dirs in /etc & /var, bug #437008
	keepdir /etc/{binfmt.d,modules-load.d,tmpfiles.d}
	keepdir /etc/kernel/install.d
	keepdir /etc/systemd/{network,system,user}
	keepdir /etc/udev/rules.d

	keepdir /etc/udev/hwdb.d

	keepdir /usr/lib/systemd/{system-sleep,system-shutdown}
	keepdir /usr/lib/{binfmt.d,modules-load.d}
	keepdir /usr/lib/systemd/user-generators
	keepdir /var/lib/systemd
	keepdir /var/log/journal

	if use pam; then
		if use selinux; then
			newpamd "${FILESDIR}"/systemd-user-selinux.pam systemd-user
		else
			newpamd "${FILESDIR}"/systemd-user.pam systemd-user
		fi
	fi

	if use kernel-install; then
		# Dummy config, remove to make room for sys-kernel/installkernel
		rm "${ED}/usr/lib/kernel/install.conf" || die
	fi

	use ukify && python_fix_shebang "${ED}"
	use boot && secureboot_auto_sign
}

migrate_locale() {
	local envd_locale_def="${EROOT}/etc/env.d/02locale"
	local envd_locale=( "${EROOT}"/etc/env.d/??locale )
	local locale_conf="${EROOT}/etc/locale.conf"

	if [[ ! -L ${locale_conf} && ! -e ${locale_conf} ]]; then
		# If locale.conf does not exist...
		if [[ -e ${envd_locale} ]]; then
			# ...either copy env.d/??locale if there's one
			ebegin "Moving ${envd_locale} to ${locale_conf}"
			mv "${envd_locale}" "${locale_conf}"
			eend ${?} || FAIL=1
		else
			# ...or create a dummy default
			ebegin "Creating ${locale_conf}"
			cat > "${locale_conf}" <<-EOF
				# This file has been created by the sys-apps/systemd ebuild.
				# See locale.conf(5) and localectl(1).

				# LANG=${LANG}
			EOF
			eend ${?} || FAIL=1
		fi
	fi

	if [[ ! -L ${envd_locale} ]]; then
		# now, if env.d/??locale is not a symlink (to locale.conf)...
		if [[ -e ${envd_locale} ]]; then
			# ...warn the user that he has duplicate locale settings
			ewarn
			ewarn "To ensure consistent behavior, you should replace ${envd_locale}"
			ewarn "with a symlink to ${locale_conf}. Please migrate your settings"
			ewarn "and create the symlink with the following command:"
			ewarn "ln -s -n -f ../locale.conf ${envd_locale}"
			ewarn
		else
			# ...or just create the symlink if there's nothing here
			ebegin "Creating ${envd_locale_def} -> ../locale.conf symlink"
			ln -n -s ../locale.conf "${envd_locale_def}"
			eend ${?} || FAIL=1
		fi
	fi
}

pkg_preinst() {
	if [[ -e ${EROOT}/etc/sysctl.conf ]]; then
		# Symlink /etc/sysctl.conf for easy migration.
		dosym ../../../etc/sysctl.conf /usr/lib/sysctl.d/99-sysctl.conf
	fi

	if ! use boot && has_version "sys-apps/systemd[gnuefi(-)]"; then
		ewarn "The 'gnuefi' USE flag has been renamed to 'boot'."
		ewarn "Make sure to enable the 'boot' USE flag if you use systemd-boot."
	fi
}

pkg_postinst() {
	systemd_update_catalog

	# Keep this here in case the database format changes so it gets updated
	# when required.
	systemd-hwdb --root="${ROOT}" update

	udev_reload || FAIL=1

	# Bug 465468, make sure locales are respected, and ensure consistency
	# between OpenRC & systemd
	migrate_locale

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		if type systemctl &>/dev/null; then
			systemctl --root="${ROOT:-/}" enable getty@.service remote-fs.target || FAIL=1
		fi
		elog "To enable a useful set of services, run the following:"
		elog "  systemctl preset-all --preset-mode=enable-only"
	fi

	if [[ -L ${EROOT}/var/lib/systemd/timesync ]]; then
		rm "${EROOT}/var/lib/systemd/timesync"
	fi

	if [[ -z ${ROOT} && -d /run/systemd/system ]]; then
		ebegin "Reexecuting system manager (systemd)"
		systemctl daemon-reexec
		eend $? || FAIL=1

		# https://lists.freedesktop.org/archives/systemd-devel/2024-June/050466.html
		ebegin "Signaling user managers to reexec"
		systemctl kill --kill-whom='main' --signal='SIGRTMIN+25' 'user@*.service'
		eend $?
	fi

	if [[ ${FAIL} ]]; then
		eerror "One of the postinst commands failed. Please check the postinst output"
		eerror "for errors. You may need to clean up your system and/or try installing"
		eerror "systemd again."
		eerror
	fi

	if use boot; then
		optfeature "installing kernels in systemd-boot's native layout and update loader entries" \
			"sys-kernel/installkernel[systemd-boot]"
	fi
	if use ukify; then
		optfeature "generating unified kernel image on each kernel installation" \
			"sys-kernel/installkernel[ukify]"
	fi
}

pkg_prerm() {
	# If removing systemd completely, remove the catalog database.
	if [[ ! ${REPLACED_BY_VERSION} ]]; then
		rm -f -v "${EROOT}"/var/lib/systemd/catalog/database
	fi
}
