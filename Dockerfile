FROM ubuntu:20.04
LABEL maintainer=musihin_sergei@mail.ru

ENV DEBIAN_FRONTEND=noninteractive 

COPY rules/88-nuand-bladerf1.rules.in /etc/udev/rules.d/88-nuand-bladerf1.rules.in
COPY rules/88-nuand-bladerf2.rules.in /etc/udev/rules.d/88-nuand-bladerf2.rules.in
COPY rules/88-nuand-bootloader.rules.in /etc/udev/rules.d/88-nuand-bootloader.rules.in
RUN chmod 644 /etc/udev/rules.d/88-nuand-*.rules.in

RUN apt-get update
RUN apt install -y software-properties-common apt-utils sudo

RUN adduser --disabled-password --gecos '' blade
RUN adduser blade sudo

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


#RUN useradd -m blade && echo "blade:blade" | chpasswd && adduser blade sudo
RUN usermod -aG plugdev blade
RUN usermod -aG audio blade

RUN mkdir -p /var/run/dbus
RUN dbus-uuidgen > /var/lib/dbus/machine-id
RUN dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

RUN add-apt-repository ppa:nuandllc/bladerf
RUN apt-get update
RUN apt-get install -y bladerf

RUN apt-get install -y libbladerf-dev
RUN apt-get install -y bladerf-firmware-fx3     # firmware for all models of bladeRF
RUN apt-get install -y bladerf-firmware-fx3     # firmware for all models of bladeRF
RUN apt-get install -y bladerf-fpga-hostedx40   # for bladeRF x40
RUN apt-get install -y bladerf-fpga-hostedx115  # for bladeRF x115
RUN apt-get install -y bladerf-fpga-hostedxa4   # for bladeRF 2.0 Micro A4
RUN apt-get install -y bladerf-fpga-hostedxa9   # for bladeRF 2.0 Micro A9

RUN apt-get install -y libusb-1.0-0-dev libusb-1.0-0 git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy \
   python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
   libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
   liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
   python3-zmq python3-scipy python3-gi python3-gi-cairo gir1.2-gtk-3.0 \
   libcodec2-dev libgsm1-dev libqt5svg5-dev libpulse-dev pulseaudio alsa-base libasound2 libasound2-dev

USER blade
ENV HOME /home/blade
ENV UNAME blade

#RUN git clone https://github.com/Nuand/bladeRF.git ./bladeRF
#WORKDIR bladeRF/host
#RUN mkdir ./build
#WORKDIR build 
#RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_UDEV_RULES=ON ../

WORKDIR $HOME
# VOLK
########
RUN git clone --recursive https://github.com/gnuradio/volk.git
WORKDIR $HOME/volk/
RUN echo $PWD
RUN mkdir build 
WORKDIR $HOME/volk/build
RUN cmake ..
RUN make -j$(nproc)
RUN sudo make install
RUN sudo ldconfig

# GNURADIO
############
RUN sudo apt install -y pybind11-dev python3-matplotlib libsndfile1-dev

WORKDIR $HOME
RUN git clone https://github.com/gnuradio/gnuradio.git -b maint-3.9

WORKDIR $HOME/gnuradio
RUN mkdir build 
WORKDIR $HOME/gnuradio/build
RUN cmake -DENABLE_INTERNAL_VOLK=OFF -DCMAKE_BUILD_TYPE=Release ..
RUN make -j$(nproc)
RUN sudo make install

# gr-iqbal
############
WORKDIR $HOME
RUN git clone git://git.osmocom.org/gr-iqbal
WORKDIR $HOME/gr-iqbal
RUN git submodule update --init --recursive
RUN mkdir build
WORKDIR $HOME/gr-iqbal/build
RUN cmake ..
RUN make -j$(nproc) 
RUN sudo make install && sudo ldconfig

# gr-osmosdr
#############
WORKDIR $HOME
RUN git clone https://git.osmocom.org/gr-osmosdr
WORKDIR $HOME/gr-osmosdr
RUN mkdir build 
WORKDIR $HOME/gr-osmosdr/build/
RUN cmake ..
RUN make -j$(nproc)
RUN sudo make install && sudo ldconfig

#GQRX
#############
WORKDIR $HOME
RUN git clone https://github.com/csete/gqrx.git
WORKDIR $HOME/gqrx/
RUN mkdir build 
WORKDIR $HOME/gqrx/build/
RUN cmake ..
RUN make -j$(nproc)
RUN sudo make install

COPY pulse-client.conf /etc/pulse/client.conf

WORKDIR $HOME
# entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]





