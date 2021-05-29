#!/bin/bash

set -x

# hack but works
xhost +

sudo docker run \
  -it --rm --privileged \
  -v /dev/bus/usb:/dev/bus/usb \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -e DISPLAY=unix$DISPLAY \
  -u root \
  gnuradio /bin/bash
