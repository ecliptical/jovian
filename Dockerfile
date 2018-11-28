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
    gnupg2

# Install Node.js
RUN wget -qO- https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

# Install Yarn
RUN wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends yarn \
    && apt-get clean -y \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /var/lib/apt/lists/*

# Install Google Drive support
RUN jupyter labextension install @jupyterlab/google-drive

# Install IJavaScript
RUN yarn global add ijavascript

USER jovyan
RUN ijsinstall
RUN conda install -q -y -c conda-forge ipywidgets

# Modify startup script to run ijavascript
USER root
RUN printf "#!/bin/bash\n$(which ijsnotebook)\n" \
    > /usr/local/bin/start-notebook.sh

# Switch back to jovyan to avoid accidental container runs as root
USER jovyan
