# Stage 1: Build stage
FROM ubuntu:22.04 AS build

# Install dependencies for build
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    cmake \
    git \
    libcurl4-openssl-dev \
    rapidjson-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone dpp library (official repo)
RUN git clone --depth=1 https://github.com/brainboxdotcc/DPP.git

# Build and install dpp library
WORKDIR /app/DPP/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON
RUN make -j$(nproc)
RUN make install

# Copy your source code
WORKDIR /app
COPY upArrow.cpp .

# Compile your app, link curl, dpp, and ssl libs
RUN g++ -std=c++20 -g upArrow.cpp -o upArrow -lcurl -ldpp -lssl -lcrypto -pthread

# Stage 2: Runtime stage
FROM ubuntu:22.04

# Install runtime dependencies (curl, ssl)
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Copy binary from build stage
COPY --from=build /app/upArrow /usr/local/bin/upArrow

CMD ["/usr/local/bin/upArrow"]
