#!/usr/bin/env bash

set -xeuo pipefail

RUBY_VERSION="${RUBY_VERSION:-2.7.1}"
VIPS_VERSION="${VIPS_VERSION:-8.10.6}"
FFMPEG_VERSION="${FFMPEG_VERSION:-4.3.2}"

COMMON_BUILD_DEPS="
  curl ca-certificates build-essential pkg-config git
"
RUBY_BUILD_DEPS="libssl-dev zlib1g-dev"
FFMPEG_BUILD_DEPS="libvpx-dev nasm"
VIPS_BUILD_DEPS="
  libfftw3-dev libwebp-dev liborc-dev liblcms2-dev libpng-dev
  libjpeg-turbo8-dev libexpat1-dev libglib2.0-dev libgif-dev libexif-dev
"
DANBOORU_RUNTIME_DEPS="
  mkvtoolnix postgresql-client-12 libpq5 libxml2 libxslt1.1 zlib1g
  libfftw3-3 libwebp6 libwebpmux3 libwebpdemux2 liborc-0.4.0 liblcms2-2
  libpng16-16 libjpeg-turbo8 libexpat1 libglib2.0 libgif7 libexif12
  libvpx6
"

apt_install() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

install_asdf() {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf
}

install_vips() {
  apt_install $VIPS_BUILD_DEPS

  VIPS_URL="https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz"
  curl -L "$VIPS_URL" | tar -C /usr/local/src -xzvf -
  cd /usr/local/src/vips-${VIPS_VERSION}

  ./configure --disable-static
  CFLAGS="-O2" make -j "$(nproc)"
  make install
  ldconfig

  vips --version
}

install_ffmpeg() {
  apt_install $FFMPEG_BUILD_DEPS

  FFMPEG_URL="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${FFMPEG_VERSION}.tar.gz"
  curl -L "$FFMPEG_URL" | tar -C /usr/local/src -xzvf -
  cd /usr/local/src/FFmpeg-n${FFMPEG_VERSION}

  ./configure --disable-ffplay --disable-network --disable-doc --enable-libvpx
  make -j "$(nproc)"
  cp ffmpeg ffprobe /usr/local/bin

  ffmpeg -version
  ffprobe -version
}

install_ruby() {
  apt_install $RUBY_BUILD_DEPS

  asdf plugin add ruby
  RUBY_BUILD_OPTS="--verbose" RUBY_CONFIGURE_OPTS="--disable-install-doc" asdf install ruby "$RUBY_VERSION"
  asdf global ruby "$RUBY_VERSION"

  ruby --version
}

cleanup() {
  apt-get purge -y $COMMON_BUILD_DEPS $RUBY_BUILD_DEPS $VIPS_BUILD_DEPS $FFMPEG_BUILD_DEPS
  apt-get purge -y --allow-remove-essential \
    e2fsprogs git libglib2.0-bin libglib2.0-doc mount perl-modules-5.30 procps \
    python3 readline-common shared-mime-info tzdata
  apt-get autoremove -y

  rm -rf \
    /var/lib/apt/lists/* \
    /var/log/* \
    /usr/local/share/gtk-doc \
    /usr/local/src \
    /usr/share/doc/* \
    /usr/share/info/* \
    /usr/share/gtk-doc

  cd /
}

apt-get update
apt_install $COMMON_BUILD_DEPS $DANBOORU_RUNTIME_DEPS
install_asdf
install_ffmpeg
install_vips
install_ruby
cleanup
