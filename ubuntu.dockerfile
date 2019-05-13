ARG OS_TAG
FROM ubuntu:$OS_TAG

# volume map these to host volumes, else all source and build results will remain in container
# gnucash: contains git clone of gnucash source
# build: build destination of make
VOLUME [ "/gnucash", "/build" ]

HEALTHCHECK --start-period=30s --interval=60s --timeout=10s \
    CMD true

# setup the OS build environment; update needs to be included in installs otherwise older apt database is cached in docker layer
RUN sed -i"" "s/^# deb-src/deb-src/" /etc/apt/sources.list
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get build-dep -qq gnucash > /dev/null && \
    apt-get install -qq tzdata git bash-completion make swig xsltproc texinfo ninja-build libboost-all-dev libgtk-3-dev \
            aqbanking-tools libdbd-sqlite3 libdbd-pgsql libdbd-mysql > /dev/null
RUN apt-get install -qq cmake$(apt-cache policy cmake|grep -q "Candidate: 2" && echo 3) \
            libwebkit2gtk-$(apt-cache policy libwebkit2gtk-4.0|grep -q "Candidate: [0-9]" && echo 4 || echo 3).0-dev > /dev/null && \
    # why language-pack-fr and not all supported? Perhaps parameterize with ARG
    apt-get --reinstall install -qq language-pack-en language-pack-fr > /dev/null && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# cmake requires gtest
RUN git clone https://github.com/google/googletest -b release-1.8.0 gtest

# environment vars
RUN update-locale LANG=${LANG:-en_US.UTF-8}
ENV LANG=${LANG:-en_US.UTF-8}
ENV GTEST_ROOT=/gtest/googletest
ENV GMOCK_ROOT=/gtest/googlemock
ENV BUILDTYPE=${BUILDTYPE:-cmake-make}

# install startup files
COPY commonbuild afterfailure ubuntubuild /
RUN chmod u=rx,go= /commonbuild /afterfailure /ubuntubuild
CMD [ "/ubuntubuild" ]
