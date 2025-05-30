# ----------- Stage 1: Build ------------
FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install base dev tools and libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    libssl-dev \
    libcurl4-openssl-dev \
    rapidjson-dev

# Build libDPP
WORKDIR /deps
RUN git clone --branch master https://github.com/brainboxdotcc/DPP.git
WORKDIR /deps/DPP
RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release && make -j$(nproc) && make install

# App source
WORKDIR /app
COPY upArrow.cpp .

# Compile your app
RUN g++ -std=c++20 -g -o upArrow upArrow.cpp \
    -ldpp -lcurl -lssl -lcrypto

# ----------- Stage 2: Runtime ------------
FROM ubuntu:22.04

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/upArrow /usr/local/bin/upArrow

CMD ["/usr/local/bin/upArrow"]
