# Stage 1: Build stage
FROM ubuntu:latest AS build

# Install build-essential for compiling C++ code
RUN apt-get update && apt-get install -y build-essential

# Install Curl
RUN apt-get update && apt-get install -y libcurl4-openssl-dev

# Install D++
RUN apt install wget
RUN wget -O dpp.deb https://dl.dpp.dev/
RUN dpkg -i dpp.deb

# Set the working directory
WORKDIR /app

# Copy the source code into the container
COPY upArrow.cpp .

# Compile the C++ code statically to ensure it doesn't depend on runtime libraries
RUN g++ -o upArrow upArrow.cpp -static

# Stage 2: Runtime stage
FROM scratch

# Copy the static binary from the build stage
COPY --from=build /app/upArrow /upArrow

# Command to run the binary
CMD ["/upArrow"]