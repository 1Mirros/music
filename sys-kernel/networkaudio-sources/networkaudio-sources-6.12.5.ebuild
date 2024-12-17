# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="8"
K_EXP_GENPATCHES_NOUSE="1"

inherit kernel-2
detect_version

DESCRIPTION="NetworkAudio Kernel sources with Gentoo patchset, naa patches and diretta host."
HOMEPAGE="https://github.com/zhjie/zhjie_gentoo_repo"
LICENSE+=" CDDL"
KEYWORDS="amd64"
IUSE="naa bmq bore diretta amd_pstate"
REQUIRED_USE="
    bmq? ( !bore )
    bore? ( !bmq )
"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI}"

src_unpack() {
    UNIPATCH_LIST_DEFAULT=""
    UNIPATCH_EXCLUDE=""
    kernel-2_src_unpack
}

src_prepare() {
    # naa patch
    if use naa; then
        eapply "${FILESDIR}/naa/0005-Add-is_volatile-USB-mixer-feature-and-fix-mixer-cont.patch"
        eapply "${FILESDIR}/naa/0006-Adjust-USB-isochronous-packet-size.patch"
        eapply "${FILESDIR}/naa/0007-Change-DSD-silence-pattern-to-avoid-clicks-pops.patch"
    fi

    # cachy patch
    eapply "${FILESDIR}/cachy/0001-amd-cache-optimizer.patch"
    if use amd_pstate; then
        eapply "${FILESDIR}/cachy/0002-amd-pstate.patch"
    fi
    eapply "${FILESDIR}/cachy/0003-autofdo.patch"
    eapply "${FILESDIR}/cachy/0004-bbr3.patch"
    eapply "${FILESDIR}/cachy/0005-cachy.patch"
    eapply "${FILESDIR}/cachy/0006-crypto.patch"
    eapply "${FILESDIR}/cachy/0007-fixes.patch"
    eapply "${FILESDIR}/cachy/0009-perf-per-core.patch"
    eapply "${FILESDIR}/cachy/0012-zstd.patch"

    # highhz patch
    eapply "${FILESDIR}/highhz/0001-high-hz-0.patch"
    eapply "${FILESDIR}/highhz/0001-high-hz-1.patch"
    eapply "${FILESDIR}/highhz/0001-high-hz-2.patch"

    # bmq scheduler
    if use bmq; then
        eapply "${FILESDIR}/bmq/5020_BMQ-and-PDS-io-scheduler-v6.12-r0.patch"
    fi

    # bore scheduler
    if use bore; then
        eapply "${FILESDIR}/bore/0001-bore-cachy.patch"
    fi

    # diretta alsa host drive
    if use diretta; then
        eapply "${FILESDIR}/diretta/diretta_alsa_host.patch"
        eapply "${FILESDIR}/diretta/diretta_alsa_host_11_22.patch"
    fi

    # cloudflare patch
    eapply "${FILESDIR}/xanmod/net/tcp/cloudflare/0001-tcp-Add-a-sysctl-to-skip-tcp-collapse-processing-whe.patch"

    rm "${S}/tools/testing/selftests/tc-testing/action-ebpf"
    eapply_user
}
