# Stage 1: Build stage
FROM ubuntu:latest AS build

# Install build-essential for compiling C++ code
RUN apt-get update && apt-get install -y build-essential

# Install Curl
RUN apt-get update && apt-get install -y libcurl4-openssl-dev

# Install D++
RUN apt-get update && apt-get install -y wget libopus0 libopus-dev
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        wget -O dpp.deb https://github.com/brainboxdotcc/DPP/releases/download/v10.1.2/libdpp-10.1.2-linux-x64.deb; \
    elif [ "$ARCH" = "arm64" ]; then \
        wget -O dpp.deb https://github.com/brainboxdotcc/DPP/releases/download/v10.1.2/libdpp-10.1.2-linux-rpi-arm64.deb; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi
RUN apt-get install -y ./dpp.deb

# Install rapidJson
RUN apt-get update && apt-get install -y rapidjson-dev

# Set the working directory
WORKDIR /app

# Copy the source code into the container
COPY upArrow.cpp .

# Compile the C++ code dynamically
RUN g++ -o upArrow upArrow.cpp -lcurl -ldpp

# Stage 2: Runtime stage
FROM ubuntu:latest

# Copy the binary from the build stage
COPY --from=build /app/upArrow /upArrow

# Command to run the binary
CMD ["/upArrow"]