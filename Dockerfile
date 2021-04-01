# Dockerfile created by merging the two Dockerfiles in tags/0.85, folders docker/{solver,webservice}

FROM ubuntu:20.04
EXPOSE 8000
ENV ASTROMETRY_VERSION=0.85

##########
# SOLVER #
##########

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get install -y apt-utils && \
    apt-get install -y --no-install-recommends \
    build-essential \
    make \
    gcc \
    git \
    file \
    pkg-config \
    wget \
    curl \
    swig \
    netpbm \
    wcslib-dev \
    wcslib-tools \
    zlib1g-dev \
    libbz2-dev \
    libcairo2-dev \
    libcfitsio-dev \
    libcfitsio-bin \
    libgsl-dev \
    libjpeg-dev \
    libnetpbm10-dev \
    libpng-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-pil \
    python3-tk \
    python3-setuptools \
    python3-wheel \
    python3-numpy \
    python3-scipy \
    python3-matplotlib \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Pip installs
RUN pip3 install --no-cache-dir fitsio astropy

RUN mkdir /src
WORKDIR /src

# Astrometry.net
RUN git clone https://github.com/dstndstn/astrometry.net.git astrometry \
    && cd astrometry \
    && git checkout tags/${ASTROMETRY_VERSION} \
    && make \
    && make py \
    && make extra \
    && make install INSTALL_DIR=/usr/local

# python = python3
RUN ln -s /usr/bin/python3 /usr/bin/python
ENV PYTHONPATH=/usr/local/lib/python

##############
# WEBSERVICE #
##############

RUN pip3 install --no-cache-dir Django

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-wsgi-py3 \
    less \
    emacs-nox

RUN pip3 install --no-cache-dir \
    social-auth-core django-social-auth3 social-auth-app-django

WORKDIR /src/astrometry/net

RUN ln -s settings_test.py settings.py

# Yuck!  The installed 'astrometry' package conflicts with '.', so paste it in...
RUN rm -R /usr/local/lib/python/astrometry/net && \
    ln -s /src/astrometry/net /usr/local/lib/python/astrometry/net

RUN mkdir appsecrets && \
    touch appsecrets/__init__.py && \
    touch appsecrets/auth.py
RUN cp /src/astrometry/docker/webservice/django_db.py /src/astrometry/net/appsecrets/

RUN mv migrations/* /tmp && \
    python manage.py makemigrations && \
    python manage.py migrate && \
    python manage.py makemigrations net && \
    python manage.py migrate net && \
    python manage.py loaddata fixtures/initial_data.json && \
    python manage.py loaddata fixtures/flags.json

##################
# CUSTOMIZATIONS #
##################

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    openssh-server \
    screen
COPY setup-and-start-nova.sh .
CMD bash setup-and-start-nova.sh
