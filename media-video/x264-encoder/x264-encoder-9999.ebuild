# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Bump with media-libs/x264

inherit flag-o-matic toolchain-funcs

DESCRIPTION="A free commandline encoder for X264/AVC streams"
HOMEPAGE="https://www.videolan.org/developers/x264.html"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://code.videolan.org/videolan/x264.git"
else
	X264_COMMIT="4613ac3c15fd75cebc4b9f65b7fb95e70a3acce1"
	SRC_URI="https://code.videolan.org/videolan/x264/-/archive/${X264_COMMIT}/x264-${X264_COMMIT}.tar.bz2 -> ${P/-encoder}.tar.bz2"
	KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~sparc ~x86"
	S="${WORKDIR}/${PN/-encoder}-${X264_COMMIT}"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="+lto avisynthplus custom-cflags ffmpeg ffmpegsource +interlaced mp4 +threads opencl"
REQUIRED_USE="ffmpegsource? ( ffmpeg )"

RDEPEND="
    opencl? ( >=virtual/opencl-0-r3 )
	~media-libs/x264-${PV}[interlaced=,threads=]
	ffmpeg? ( media-video/ffmpeg:= )
	ffmpegsource? ( media-libs/ffmpegsource )
	mp4? ( >=media-video/gpac-0.5.2:= )
"
ASM_DEP=">=dev-lang/nasm-2.13"
DEPEND="
	${RDEPEND}
	amd64? ( ${ASM_DEP} )
	x86? ( ${ASM_DEP} )
	opencl? ( dev-lang/perl )
    avisynthplus? ( media-video/avisynth+ )
"
BDEPEND="virtual/pkgconfig"

src_configure() {
	tc-export CC

	if [[ ${ABI} == x86 || ${ABI} == amd64 ]]; then
		export AS="nasm"
	else
		export AS="${CC}"
	fi

	# let upstream pick the optimization level by default
	use custom-cflags || filter-flags -O?

	./configure \
		--prefix="${EPREFIX}"/usr \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--system-libx264 \
		--host="${CHOST}" \
		--disable-lsmash \
		$(usex avisynthplus "" "--disable-avisynth") \
		$(usex lto "--enable-lto" "") \
        $(usex opencl "" "--disable-opencl") \
		$(usex ffmpeg "" "--disable-lavf --disable-swscale") \
		$(usex ffmpegsource "" "--disable-ffms") \
		$(usex interlaced "" "--disable-interlaced") \
		$(usex mp4 "" "--disable-gpac") \
		$(usex threads "" "--disable-thread") || die

	# this is a nasty workaround for bug #376925 for x264 that also applies
	# here, needed because as upstream doesn't like us fiddling with their CFLAGS
	if use custom-cflags; then
		local cflags
		cflags="$(grep "^CFLAGS=" config.mak | sed 's/CFLAGS=//')"
		cflags="${cflags//$(get-flag O)/}"
		cflags="${cflags//-O? /$(get-flag O) }"
		cflags="${cflags//-g /}"
		sed -i "s:^CFLAGS=.*:CFLAGS=${cflags//:/\\:}:" config.mak
	fi
}
