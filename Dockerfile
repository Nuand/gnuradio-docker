FROM pybombs/pybombs-commondeps:2.3.4
LABEL maintainer=musihin_sergei@mail.ru

RUN mkdir ~/pybombs/
RUN pybombs config --package gnuradio gitrev v3.9.0.0
RUN pybombs config --package gr-osmosdr gitrev dev-gr-3.9
RUN pybombs prefix init ~/pybombs/bladeRF -a bladeRF -R gnuradio-default
