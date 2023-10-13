FROM ubuntu:20.04

# Download system packages
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    curl \
    libffi-dev \
    git \
    openssh-client \
    && \
  apt-get autoremove && \
  apt-get clean

# Install R
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get install -y --no-install-recommends \
    r-base \
    && \
  apt-get autoremove && \
  apt-get clean

# Special system package required for RGI
RUN cd ~ && \
  wget https://mirrors.kernel.org/ubuntu/pool/main/libf/libffi/libffi6_3.2.1-8_amd64.deb && \
  apt install ./libffi6_3.2.1-8_amd64.deb && \
  rm libffi6_3.2.1-8_amd64.deb

# Install micromamba
RUN cd ~ && \
  touch .bashrc && \
  wget -O - https://web.archive.org/web/20230328162543if_/http://micro.mamba.pm/install.sh | bash
ENV PATH=/root/.local/bin/:$PATH

# Clone git repository
RUN cd ~ && git clone https://github.com/ccm-bioinfo/cambda2023 git

# Create all miniconda/micromamba environments
RUN cd ~ && ls ~/git/07_reproducible_code/Dependencies/*.yml | while read yml; do \
  micromamba create -y -f $yml; \
  done

# Create all Python environments from requirement files
RUN cd ~ && ls ~/git/07_reproducible_code/Dependencies/*.txt | while read txt; do \
  micromamba run -n rpy python3 -m venv "$(basename "${txt%%.txt}")" && \
  "$(basename "${txt%%.txt}")"/bin/pip install -r $txt; \
  done

# Pull git on lauch
ENTRYPOINT git -C ~/git/ pull -q && /bin/bash
