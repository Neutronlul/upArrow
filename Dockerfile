# Stage 1: Build
FROM ubuntu:20.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libcurl4-openssl-dev \
    libssl-dev \
    rapidjson-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source code
COPY upArrow.cpp .

# Compile the application
RUN g++ -std=c++20 -g upArrow.cpp -o upArrow \
    -I/usr/include/rapidjson \
    -lcurl \
    -lssl \
    -lcrypto

# Stage 2: Runtime
FROM ubuntu:20.04

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary
COPY --from=build /app/upArrow /upArrow

# Set the entry point
CMD ["/upArrow"]:contentReference[oaicite:83]{index=83}
