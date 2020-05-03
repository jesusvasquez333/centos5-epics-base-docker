FROM centos:5.11

# Patch the Cento repository locations
COPY CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo

# Install system packages
RUN yum -y update \
    && yum install -y \
        perl \
        gcc \
        gcc-c++ \
        make \
    && yum clean all -y

# Install EPICS
# Notes:
# - I had problems with the old version of wget and ssl certificates,
#   so for this example downloaded EPICS base to my host, and I'm adding
#   here this local copy
# -  I also had problems building with readline, so for this example
#    I'm building without readline support.
ENV EPICS_TOP /usr/local/src/epics/
ENV EPICS_BASE_TOP ${EPICS_TOP}/epics-base-R3.14.12
ENV EPICS_HOST_ARCH linux-x86_64
RUN mkdir -p ${EPICS_TOP}
ADD R3.14.12.tar.gz ${EPICS_TOP}
WORKDIR ${EPICS_BASE_TOP}
RUN sed -i -e 's|COMMANDLINE_LIBRARY = READLINE|#COMMANDLINE_LIBRARY = READLINE|g' configure/os/CONFIG_SITE.Common.linux-x86* \
    && make clean && make && make install

# Update env variables
ENV PATH=${EPICS_BASE_TOP}/bin/${EPICS_HOST_ARCH}:${PATH}
ENV LD_LIBRARY_PATH=${EPICS_BASE_TOP}/lib/${EPICS_HOST_ARCH}:${LD_LIBRARY_PATH}

# Set the work directory to root
WORKDIR /

# Run /bin/bash by default
ENTRYPOINT ["/bin/bash"]