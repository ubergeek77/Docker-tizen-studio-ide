# ubergeek77/tizen-studio-ide:2.5

FROM phusion/baseimage:0.10.2

# These are the IDs that will be used by the container. They MUST match the host UID/GID
# If these are not the same as your host user's IDs, please change them

ARG UID=1000
ARG GID=1000

# The non-root user that will be used to run Tizen Studio
ARG T_USER=tizen

# Add the non-root user to the system
RUN groupadd -g ${GID} -o ${T_USER} && \
	useradd -m -d /home/${T_USER} -u ${UID} -g ${GID} -o -s /bin/bash ${T_USER} && \
	mkdir -p /run/user/$UID && \
	chown ${UID}:${GID} /run/user/${UID}

# Install dependencies for Tizen Studio
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
	add-apt-repository -y ppa:webupd8team/java && \
	apt-get update && \
	apt-get install -y \
		acl \
		bridge-utils \
		cpio \
		dbus-x11 \
		expect \
		gettext \
		libfontconfig1 \
		libglib2.0-0 \
		libjpeg-turbo8 \
		libpixman-1-0 \
		libpng12-0 \
		libsdl1.2debian \
		libsm6 \
		libv4l-0 \
		libwebkitgtk-1.0-0 \
		libx11-xcb1 \
		libxcb-icccm4 \
		libxcb-image0 \
		libxcb-randr0 \
		libxcb-render-util0 \
		libxcb-shape0 \
		libxcb-xfixes0 \
		libxi6 \
		make \
		openvpn \
		oracle-java8-installer \
		pciutils \
		python2.7 \
		rpm2cpio \
		ruby \
		zip
# Tizen Studio requires Google Chrome in order to debug web applications.
# As per Samsung's own System Requirements for Tizen Studio, Google Chrome version 52 is required
# https://developer.tizen.org/ko/development/tizen-studio/download/installing-tizen-studio/prerequisites?langredirect=1#chrome
# Install Google Chrome
RUN wget https://www.slimjet.com/chrome/download-chrome.php?file=lnx%2Fchrome64_52.0.2743.116.deb -O /google_chrome.deb
RUN dpkg -i /google_chrome.deb; exit 0
RUN apt-get install -fy && \
	rm /google_chrome.deb

# Clear the apt cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Download Tizen Studio installer
# If you want to download a different version of Tizen Studio, you may specify it in the argument below:
ARG T_VERSION=2.5
ARG T_BINARY=web-cli_Tizen_Studio_${T_VERSION}_ubuntu-64.bin
RUN wget http://download.tizen.org/sdk/Installer/tizen-studio_${T_VERSION}/${T_BINARY} \
	-O /home/${T_USER}/${T_BINARY} && \
	chown ${UID}:${GID} /home/${T_USER}/${T_BINARY} && \
	chmod +x /home/${T_USER}/${T_BINARY}

# Switch to the non-root user to run the installer
USER ${T_USER}

# Install Tizen Studio
RUN /home/${T_USER}/${T_BINARY} --accept-license /home/${T_USER}/tizen-studio && \
	/home/${T_USER}/tizen-studio/package-manager/package-manager-cli.bin install --accept-license \
	-d official \
	-s Tizen_Studio_${T_VERSION} \
	NativeIDE

# Remove the installer file
RUN rm /home/${T_USER}/${T_BINARY}

# Switch back to the root user so that phusion's init scripts will work properly
USER root