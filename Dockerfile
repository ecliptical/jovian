FROM jupyter/minimal-notebook:latest

LABEL maintainer="Peter Nehrer <pnehrer@eclipticalsoftware.com>"

# Install ijavascript dependencies. See https://github.com/n-riesco/ijavascript
USER root
ENV DEBIAN_FRONTEND noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libzmq3-dev \
    gnupg2 \
    && apt-get clean -y \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN wget --quiet -O - https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

# Install IJavaScript
RUN npm config set user 0
RUN npm config set unsafe-perm true
RUN npm install -g ijavascript lodash

USER jovyan
RUN ijsinstall
RUN conda install -q -y -c conda-forge ipywidgets

# Modify startup script to run ijavascript
USER root
RUN printf "#!/bin/bash\n$(which ijsnotebook)\n" \
    > /usr/local/bin/start-notebook.sh

# Switch back to jovyan to avoid accidental container runs as root
USER jovyan
