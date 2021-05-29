FROM ubuntu:20.04
LABEL maintainer=musihin_sergei@mail.ru

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update
RUN apt install -y software-properties-common apt-utils

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

RUN apt-get install -y libusb-1.0-0-dev libusb-1.0-0 

RUN apt install -y git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy \
   python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
   libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
   liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
   python3-zmq python3-scipy python3-gi python3-gi-cairo gir1.2-gtk-3.0 \
   libcodec2-dev libgsm1-dev

#RUN git clone https://github.com/Nuand/bladeRF.git ./bladeRF
#WORKDIR bladeRF/host
#RUN mkdir ./build
#WORKDIR build 
#RUN cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_UDEV_RULES=ON ../


RUN groupadd bladerf
RUN usermod -a -G bladerf root
RUN groups

#RUN make && sudo make install && sudo ldconfig
#RUN make && make install && ldconfig
#RUN apt-get install -y sudo

# VOLK
########
RUN git clone --recursive https://github.com/gnuradio/volk.git

WORKDIR /volk/build/
RUN cmake  ..
RUN make -j$(nproc)
RUN make install
RUN ldconfig
RUN volk_profile

# GNURADIO
############
WORKDIR /
RUN git clone https://github.com/gnuradio/gnuradio.git -b maint-3.8

WORKDIR /gnuradio/build/
RUN cmake -DENABLE_INTERNAL_VOLK=OFF -DCMAKE_BUILD_TYPE=Release ..
RUN make -j$(nproc)
RUN make install


# gr-osmosdr
#############
WORKDIR /
RUN git clone https://git.osmocom.org/gr-osmosdr

WORKDIR /gr-osmosdr
RUN git checkout gr3.8

WORKDIR /gr-osmosdr/build/
RUN cmake ..
RUN make -j$(nproc)
RUN make install

WORKDIR /

# entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]


