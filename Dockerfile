# Stage 1: Build stage
FROM ubuntu:latest AS build

# Install build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
    libopus-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Download and install RapidJSON (header-only library)
RUN git clone https://github.com/Tencent/rapidjson.git \
    && cd rapidjson \
    && mkdir build && cd build \
    && cmake .. -DRAPIDJSON_BUILD_TESTS=OFF -DRAPIDJSON_BUILD_EXAMPLES=OFF \
    && make install \
    && cd ../.. && rm -rf rapidjson

# Download and build DPP statically
RUN git clone https://github.com/brainboxdotcc/DPP.git \
    && cd DPP \
    && mkdir build && cd build \
    && cmake .. -DBUILD_SHARED_LIBS=OFF -DDPP_BUILD_TEST=OFF \
    && make -j$(nproc) \
    && make install \
    && cd ../.. && rm -rf DPP

# Copy the source code into the container
COPY upArrow.cpp .

# Compile the C++ code statically with all libraries
RUN g++ -o upArrow upArrow.cpp \
    -static \
    -std=c++17 \
    -ldpp \
    -lcurl \
    -lssl \
    -lcrypto \
    -lsodium \
    -lopus \
    -lz \
    -pthread

# Stage 2: Runtime stage
FROM scratch

# Copy the static binary from the build stage
COPY --from=build /app/upArrow /upArrow

# Command to run the binary
CMD ["/upArrow"]