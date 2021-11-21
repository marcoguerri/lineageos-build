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

# AUR: ncurses5-compat-libs 6.2-1
#    https://aur.archlinux.org/lib32-libstdc++5.git 


##export PATH=/home/lineageos/.local/bin/:${PATH} where there is a symlink to python2

#export USER=root

#prebuilts/sdk/tools/jack:128

#prebuilts/sdk/tools/jack-admin:123


#replace --no-proxy with --proxy false 

#needed to disable jack server

#// java 7 is not necessary??
# sudo ln -s /usr/lib/jvm/java-8-openjdk/ /usr/lib/jvm/java-8-openjdk-amd64

# clone https://github.com/LineageOS/android_device_samsung_espresso-common.git as well

# For libsrv_init, one needs https://github.com/Unlegacy-Android/proprietary_vendor_ti.git
# For galaxy tab, one needs https://github.com/andi34/proprietary_galaxy_tab2.git

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

# def get_default_revision():
#    m = ElementTree.parse(".repo/manifests/default.xml")
#    d = m.findall('default')[0]
#    r = d.get('revision')
#    return r.replace('refs/heads/', '').replace('refs/tags/', '')

RUN sudo cp /usr/sbin/curl /usr/sbin/curl-fixed
COPY --chown=lineageos artifacts/curl /usr/sbin/curl
RUN sudo chmod u+x /usr/sbin/curl

COPY --chown=lineageos artifacts/repo /home/lineageos/bin
RUN sudo chmod u+x /home/lineageos/bin/repo

COPY --chown=lineageos artifacts/build.sh /home/lineageos
RUN sudo chmod u+x /home/lineageos/build.sh

COPY --chown=lineageos artifacts/roomservice.patch /home/lineageos/android/lineage
COPY --chown=lineageos artifacts/roomservice.xml.patch /home/lineageos/android/lineage

RUN git config --global user.email "marco.guerri.dev@fastmail.com"
RUN git config --global user.name "Marco Guerri"


#RUN sudo ln -s /usr/bin/python3 /usr/sbin/python

# Add to roomservice.xml
# <project name="TheMuppets/proprietary_vendor_samsung" path="vendor/samsung" depth="1" />

# <project name="TheMuppets/proprietary_vendor_ti" path="vendor/ti" revision="master" depth="1" />


# sudo ln -s /usr/bin/python2 /usr/sbin/python

# re

