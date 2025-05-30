# Stage 1: Build stage
FROM ubuntu:24.04 AS build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    rapidjson-dev

# Install DPP from source
RUN git clone https://github.com/brainboxdotcc/DPP.git /dpp && \
    mkdir /dpp/build && \
    cd /dpp/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install

# Set working directory
WORKDIR /app

# Copy source
COPY upArrow.cpp .

# Compile
RUN g++ -std=c++20 -g upArrow.cpp -o upArrow \
    -I/usr/include/rapidjson \
    -ldpp -lcurl -lssl -lcrypto

# Stage 2: Minimal runtime
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    libcurl4 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/upArrow /upArrow

CMD ["/upArrow"]
