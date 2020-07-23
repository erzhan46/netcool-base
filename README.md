netcool-base
=========================

This is a Netcool/OMNIbus v8.1 base image.
Purpose of this image it to serve as a base for various Netcool/OMNIbus images running Object Server, probes, gateways, etc.

This image is based on latest RHEL Universal Base Image (registry.access.redhat.com/ubi8/ubi:latest) to ensure that it is built on certified secure and reliable official Red Hat container image.

This image can be used for development, testing and custom deployment purposes:
- To build custom Netcool/OMNIbus Object Server image for development and testing purposes
- To build custom image to run Netcool/OMNIbut probe or gateway not currently provided via official registry or for development and testing purposes
- To build other custom Netcool/OMNIbus images (e.g. Proxy or Firewall Bridge servers)

See (https://github.ibm.com/ybeisem/netcool-snmp-probe) for an example.

TODO:
-------------------------
- See if this image could be made official
- More examples on image usage (Object Server, Proxy, gateways, probes)
- For Object Server and probe image descendants - research source2image options(new builder image, etc.).

Pre-requisites:
-------------------------
- Docker
- Git

Quick Start
-------------------------

1. Clone this repository 
```
git clone https://github.com/erzhan46/netcool-base
```

2. Acquire Netcool/Omnibus package (64-bit Linux) from Passport Advantage (e.g. _"IBM Tivoli Netcool OMNIbus 8.1.0.21 Core - Linux 64bit Multilingual (CC3V7ML)"_ ) and copy it to omnibus8.1 directory.
```
cp TVL_NTCL_OMN_V8.1.0.21_CORE_LNX_M.zip <Dev>/netcool-base/omnibus8.1
```

3. Build the image
```
cd <Dev>/netcool-base
docker build .
```

4. Validate and tag the image
List docker images:
```
docker images
```
There should be two images:
- One about 3.03GB - this one is a 'builder' image and can be deleted to save space:
```
docker rmi --force <IMAGE ID>
```
- Another one should be about 1.68GB - this is the one to be used. This image needs to be tagged accordingly for future use:
```
docker tag <IMAGE ID> netcool-omnibus-base:8.1.0.21
docker tag <IMAGE ID> netcool-omnibus-base:latest
```

5. Optionally - run the image and check it's contents
```
docker run -ti <IMAGE ID>
```

6. Optionally - Netcool/OMNIbus base image can be pushed to online registry
```
docker tag <IMAGE ID> <registry URL>/<repository>/netcool-omnibus-base:8.1.0.21
docker push <registry URL>/<repository>/netcool-omnibus-base:8.1.0.21
```

Details
-------------------------
1. Netcool/Omnibus core package is fairly large and to save space this image built using intermediate 'builder' image.
The following is the image sizes observed during development:
- Ubi8 docker image:                                                231MB
- Omnibus (8.1.0.21) package size (compressed):                     626MB
- Ubi8 + Omnibus package:                                           873MB
- Ubi8 + Omnibus package unzipped:                                 1.61GB
- Ubi8 + Omnibus package unzipped and installed (excluding GUI):   3.03GB
- Final Netcool/OMNIbus base image:                                1.86GB

2. Netcool/Omnibus core along with IBM Installation Manager installed using netcool account in the following directories:
- /home/netcool/IBM/InstallationManager 
- /home/netcool/etc/.ibm
- /home/netcool/var/ibm
- /opt/IBM/IBMIMShared
- /opt/IBM/tivoli/netcool

3. Dockerfile contains three sections:
- Create 'system' image from ubi:latest by installing required OS packages, creating ncoadmin group and netcool user and required directories
- Install Netcool/OMNIbus in the temporary 'builder' image by uploading and uncompressing Netcool/OMNIbus package, creating ncoadmin group and netcool user and installing Netcool/OMNIbus using provided response file.
- Copy /home/netcool and /opt/IBM directories from 'builder' to 'system' image and setting up image labels and environment.

4. Other images build using Netcool/OMNIbus base image should deploy additional functionality and run Netcool/OMNIbus component using netcool user. See (https://github.com/erzhan46/netcool-snmp-probe) for an example how it could be done.
