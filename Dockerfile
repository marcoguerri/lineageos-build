FROM archlinux/base
MAINTAINER Marco Guerri

RUN useradd -m lineageos


RUN pacman -Syu --noconfirm archlinux-keyring

RUN pacman-key --init


RUN pacman -Syu --noconfirm \
	ccache \
	sudo \
    git \
    openssh \
    inetutils \
    jre7-openjdk \
    jdk7-openjdk \
    wget \
    python2 \
    lib32-glibc  \
    lib32-gcc-libs \ 
    imagemagick \
    fakeroot \
    binutils \
    gcc \
    m4 \
    patch \
    diffutils \
    zip \
    curl \
    jdk8-openjdk \
    maven \
    rsync \
    unzip \
    gawk \
    make \
    schedtool \
    python3 \
    ca-certificates-java

RUN cat /proc/sys/kernel/random/uuid  | sed 's/-//g' > /etc/machine-id

RUN echo "lineageos ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN sed 's/.*MAKEFLAGS.*/MAKEFLAGS="-j4"/' -i /etc/makepkg.conf 

USER lineageos


RUN cd $HOME &&  \
    git clone https://aur.archlinux.org/lib32-libstdc++5.git && \
    cd lib32-libstdc++5 && \
    makepkg -i --skippgpcheck --noconfirm


RUN cd $HOME &&  \
    git clone https://aur.archlinux.org/ncurses5-compat-libs.git && \
    cd ncurses5-compat-libs && \
    makepkg -i --skippgpcheck --noconfirm

RUN cd $HOME &&  \
    mkdir bin && mkdir -p android/lineage


COPY artifacts/platform-tools_r31.0.3-linux.zip /home/lineageos

RUN sudo cp /usr/sbin/curl /usr/sbin/curl-fixed
COPY --chown=lineageos artifacts/curl /usr/sbin/curl
RUN sudo chmod u+x /usr/sbin/curl

COPY --chown=lineageos artifacts/repo /home/lineageos/bin
RUN sudo chmod u+x /home/lineageos/bin/repo

COPY --chown=lineageos artifacts/build.sh /home/lineageos
RUN sudo chmod u+x /home/lineageos/build.sh

COPY --chown=lineageos artifacts/roomservice.patch /home/lineageos/android/lineage
COPY --chown=lineageos artifacts/roomservice.xml.patch /home/lineageos/android/lineage

RUN git config --global user.email "EMAIL"
RUN git config --global user.name "NAME"
