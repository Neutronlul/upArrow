# Stage 1: Build stage
FROM ubuntu:latest AS build

# Install build-essential, wget, rapidjson, curl, and other necessary packages
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    rapidjson-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install D++ library
RUN wget -O dpp.deb https://dl.dpp.dev/ && \
    dpkg -i dpp.deb && \
    rm dpp.deb

# Set the working directory
WORKDIR /app

# Copy the source code into the container
COPY upArrow.cpp .

# Compile the C++ code with D++ and curl libraries
RUN g++ -o upArrow upArrow.cpp -ldpp -lcurl

# Stage 2: Runtime stage
FROM ubuntu:latest

# Install runtime dependencies for D++ if needed
RUN apt-get update && apt-get install -y \
    libssl3 \
    libcurl4 \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from the build stage
COPY --from=build /app/upArrow /upArrow

# Command to run the binary
CMD ["/upArrow"]