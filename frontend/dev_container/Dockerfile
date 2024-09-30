FROM ubuntu:latest

# Install necessary dependencies

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget \
    ca-certificates \
    gnupg \
    iproute2 \
    net-tools \
    iputils-ping \
    traceroute \
    nmap \
    tcpdump \
    telnet \
    dnsutils \
    whois \
    htop \
    iftop \
    iotop \
    vim \
    nano \
    tmux \
    screen \
    sudo \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Set the working directory for the application
WORKDIR /app

# Copy the start script
COPY start_flutter.sh /start_flutter.sh
RUN chmod +x /start_flutter.sh

# Expose the port for the Flutter development server
EXPOSE 8081

# Set the entrypoint
ENTRYPOINT ["./start_flutter.sh"]