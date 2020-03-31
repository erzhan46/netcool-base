################################################################################
# base system
################################################################################

FROM registry.access.redhat.com/ubi8/ubi:latest as system

RUN yum repolist \
    && yum install -y unzip hostname procps-ng iputils \ 
    && groupadd -g 2000 ncoadmin \
    && useradd -d /home/netcool -m -g ncoadmin -s /bin/bash netcool \
    && mkdir /opt/IBM && chown netcool:ncoadmin /opt/IBM


################################################################################
# Netcool Omnibus installation image
################################################################################

FROM registry.access.redhat.com/ubi8/ubi:latest as builder

RUN yum repolist \
    && yum install -y unzip \
    && groupadd -g 2000 ncoadmin \
    && useradd -d /home/netcool -m -g ncoadmin -s /bin/bash netcool \
    && mkdir /opt/IBM && chown netcool:ncoadmin /opt/IBM

USER netcool

ADD --chown=netcool:ncoadmin omnibus8.1 /omnibus8.1

RUN cd /omnibus8.1 \
    && unzip -q TVL_NTCL*.zip \
    && ./install_silent.sh omnibus8.1.response.xml -acceptLicense \
    && /home/netcool/IBM/InstallationManager/eclipse/tools/imcl -s -input reset_repos.xml


################################################################################
# Merge images and create Netcool/OMNIbus base image
################################################################################
FROM system
LABEL maintainer="ybeisem@us.ibm.com"
LABEL version="8.1.0.21"
LABEL description="This is a Netcool/OMNIbus base image containing IBM Netcool/OMNIbus core v.8.1.0.21 and IBM Installation Manager v.1.8.3. The purpose of this image is to be a base image for other images running Netcool/OMNIbus Object Server and other components such as Netcool/OMNIbus probes and gateways."
LABEL netcool.omnibus.version=8.1.0.21
LABEL installationmanager.version=1.8.3


USER netcool

COPY --from=builder --chown=netcool:ncoadmin /opt/IBM/ /opt/IBM/
COPY --from=builder --chown=netcool:ncoadmin /home/netcool/ /home/netcool/


WORKDIR /home/netcool
ENV HOME=/home/netcool \
    SHELL=/bin/bash \
    NCHOME=/opt/IBM/tivoli/netcool \
    OMNIHOME=/opt/IBM/tivoli/netcool/omnibus \
    PATH=/opt/IBM/tivoli/netcool/bin:/opt/IBM/tivoli/netcool/omnibus/bin:$PATH
ENTRYPOINT ["/bin/bash"]
