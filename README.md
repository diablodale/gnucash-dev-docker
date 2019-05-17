# gnucash-dev-docker

Docker containers for automated OS setup and dev/build environ for gnucash v3+ binaries and docs  
Copyright (C) 2019 Dale Phurrough <dale@hidale.com>

## Setup

1. You need a running Docker host/engine on a Linux-based OS.
   Other host OS are not yet supported. Docker has free and easy instructions at
   <https://docs.docker.com/install/>
2. Strongly recommend you have `docker-compose` installed
   <https://github.com/docker/compose/releases>
3. `git clone` this repo into a folder on your host

## Quick Start Example

In the folder containing these files, run the following command. This will start
a Ubuntu 18.04 container, configure it, compile gnucash, and test gnucash.

```
docker-compose up -d ubuntu-18.04
```

You can view the progress using a well-known command like:
`docker logs gnucashbuild-ubuntu-18.04`

Do you have X11 or a Linux desktop configured to allow remote applications?
If yes, you can run your newly compiled gnucash with the following commands.

```bash
docker attach gnucashbuild-ubuntu-18.04  # after this, you are inside the container
make install
cd /opt/bin
export DISPLAY=mycomputer:0.0   # replace mycomputer with hostname or IP address
./gnucash
```

## Build Choices and Options

The Dockerfiles can be used direct with `docker run` or more easily with
`docker-compose`. The `docker-compose.yml` included already has support for major
releases of Ubuntu, Debian, and Arch Linux. Inspect this file to see how new
operating systems can be added or build options changed to meet your needs.

`docker-compose` documentation at <https://docs.docker.com/compose/> can help you
better understand. Naturally, you are welcome to hack `docker-compose.yml`. These
are the arguments and environment variables specific to this build solution.

| Option | Description | Example |
| :---   | :---        | :---    |
| OS_DIST | Docker image name | `OS_DIST=ubuntu` |
| OS_TAG | Version of Docker image | `OS_DIST=18.04` |
| PLATFORM_CMAKE_OPTS | [Gnucash Build Options](https://code.gnucash.org/wiki/Gnucash_Build_Options) | `-DCMAKE_INSTALL_PREFIX=/opt -DWITH_PYTHON=ON` |
| GNC_GIT_CHECKOUT | Gnucash git branch, commit, tag to clone and checkout into the container's /build directory. It will abort if /build already contains files. | `GNC_GIT_CHECKOUT=3.5` |
| BUILDTYPE | Override the default make build tool for the OS. Only `cmake-make` and `cmake-ninja` are supported. To prevent building, set to any other value, e.g. `stop`. | `BUILDTYPE=stop` |
| GNC_IGNORE_BUILD_FAIL | Set to `1` to ignores build errors/failures. Container's log retains details. | `GNC_IGNORE_BUILD_FAIL=1` |
| GNC_INSTALL | Set to `1` to automatically install gnucash in the container after build is successful. Ignores result of unit tests. | `GNC_INSTALL=1` |
| GNC_EXIT_AFTER_TEST | Set to `1` to immediately stop/exit container with test results. Container's log retains details. Great for CI like [Travis](https://travis-ci.org/). | `GNC_EXIT_AFTER_TEST=1` |
| DISPLAY | Easy way to set the `DISPLAY` environment variable for X11; enables running gnucash inside container and display to XWin on host/remote. | `DISPLAY=192.168.1.5:0.0` |

## Volumes and Files

By default, each container has its own private copy of the OS, build tools,
gnucash source files, compiled code, and test files. Docker has
[easy methods to mount host files/folders](https://docs.docker.com/compose/compose-file/compose-file-v2/#volumes)
into the container.

### Source code folder `/gnucash`

You can store and manage your gnucash source files on your host and mount them into
the container so that container can compile them.

* Builds always occur from the container's `/gnucash` folder. It should contain
  the gnucash source code.
* The gnucash build process requires read+write access to this `/gnucash` folder.
* The gnucash build process alters/create some files in the source code folder.
  *You may encounter difficult to isolate issues* if you mount the same source
  code folder into multiple containers *and* simultaneously compile.

```yaml
volumes:
    - /home/user1/source/gnucash:/gnucash
```

### Build result folder `/build`

You can receive the result of the build process on your host. This is done by
mounting a folder on your host into the container at `/build`.

* Builds results always go to the container's `/build` folder.
* The gnucash build process requires read+write access to this `/build` folder.
* The gnucash build process substantially alters this folder.
  *You may encounter difficult to isolate issues* if you mount the same
  build folder into multiple containers *and* simultaneously compile.

```yaml
volumes:
    - /home/user1/build/gnucash:/build
```

## Technical Notes

* docker-compose file version 2.4 is used to enable several of the below features
* `network_mode: host` is used to ease remote X11 use. Otherwise, an isolated
  docker network works just as well.
* `init: true` provides a init process handler for clean startup/shutdown
* `tty: true` and `stdin_open: true` are set to support running bash at the
  end of the build process
* [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
  works well with this Docker setup.
