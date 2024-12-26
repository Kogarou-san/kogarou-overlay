# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8
inherit cmake toolchain-funcs git-r3 ${SCM}
DESCRIPTION="lsmash"
HOMEPAGE="https://foo.example.org/"
if [ "${PV#9999}" != "${PV}" ] ; then
	SCM="git-r3"
	EGIT_REPO_URI="https://github.com/HomeOfAviSynthPlusEvolution/L-SMASH-Works.git"
	fi

LICENSE=""
SLOT="0"
if [ "${PV#9999}" = "${PV}" ] ; then
	KEYWORDS="~amd64"
fi
IUSE=""

# A space delimited list of portage features to restrict. man 5 ebuild
# for details.  Usually not needed.
#RESTRICT="strip"

# Run-time dependencies. Must be defined to whatever this depends on to run.
# Example:
#    ssl? ( >=dev-libs/openssl-1.0.2q:0= )
#    >=dev-lang/perl-5.24.3-r1
# It is advisable to use the >= syntax show above, to reflect what you
# had installed on your system when you tested the package.  Then
# other users hopefully won't be caught without the right version of
# a dependency.
RDEPEND="media-video/avisynth+"

# Build-time dependencies that need to be binary compatible with the system
# being built (CHOST). These include libraries that we link against.
# The below is valid if the same run-time depends are required to compile.
DEPEND="${RDEPEND}"

# Build-time dependencies that are executed during the emerge process, and
# only need to be present in the native build system (CBUILD). Example:
BDEPEND="virtual/pkgconfig"

# The following src_configure function is implemented as default by portage, so
# you only need to call it if you need a different behaviour.
src_configure() {
	tc-export CC
	# project uses cmake
	local mycmakeargs=(
	-DBUILD_AVS_PLUGIN=ON
	-DBUILD_VS_PLUGIN=OFF
	-DENABLE_DAV1D=OFF
	-DENABLE_MFX=OFF
	-DENABLE_XML2=OFF
	-DENABLE_VPX=OFF
	-DENABLE_SSE2=ON
	)
	#
	# You could use something similar to the following lines to
	# configure your package before compilation.  The "|| die" portion
	# at the end will stop the build process if the command fails.
	# You should use this at the end of critical commands in the build
	# process.  (Hint: Most commands are critical, that is, the build
	# process should abort if they aren't successful.)
	cmake_src_prepare
	cmake_src_configure

	# Note the use of --infodir and --mandir, above. This is to make
	# this package FHS 2.2-compliant.  For more information, see
	#   https://wiki.linuxfoundation.org/lsb/fhs
}

src_compile()
{
	tc-env_build cmake_build distribution
}

