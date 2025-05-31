# Stage 1: Build stage
FROM ubuntu:latest AS build

# Install build-essential, curl dev headers, RapidJSON, wget, and OpenSSL dev
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libcurl4-openssl-dev \
      rapidjson-dev \
      libssl-dev \
      wget \
      ca-certificates \
      gnupg \
      dpkg

# Install D++ (.deb provided by upstream)
RUN wget -O /tmp/dpp.deb https://dl.dpp.dev/ && \
    dpkg -i /tmp/dpp.deb || apt-get -f install -y && \
    rm -f /tmp/dpp.deb

# Set the working directory
WORKDIR /app

# Copy the C++ source code into the container
COPY upArrow.cpp .

# Compile the C++ code (linking against libcurl, D++, OpenSSL)
# Note: we drop '-static' so shared libs are used
RUN g++ upArrow.cpp -o upArrow \
      -lcurl \
      -ldpp \
      -lssl \
      -lcrypto \
      -std=c++17

# Stage 2: Runtime stage
FROM ubuntu:latest

# Install only the runtime dependencies for curl, OpenSSL, and D++
RUN apt-get update && \
    apt-get install -y \
      libcurl4 \
      libssl1.1 \
      libstdc++6 \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy the compiled binary (with its shared-lib references) from the build stage
COPY --from=build /app/upArrow /usr/local/bin/upArrow

# Make sure the D++ runtime shared library is present
# (dpkg in build stage already installed the .so under /usr/lib; no need to reinstall)
# If dpkg installed /usr/lib/libdpp.so.* then the binary will find it automatically.

# Set entrypoint / command
ENTRYPOINT ["/usr/local/bin/upArrow"]