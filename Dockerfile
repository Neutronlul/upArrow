# Stage 1: Build stage
FROM ubuntu:latest AS build

# Install build-essential for compiling C++ code
RUN apt-get update && apt-get install -y build-essential

# Install Curl
RUN apt-get update && apt-get install -y libcurl4-openssl-dev

# Install D++
RUN apt-get update && apt-get install -y wget \ libopus0
RUN wget -O dpp.deb https://dl.dpp.dev/
RUN apt-get install -y ./dpp.deb

# Install rapidJson
RUN apt-get update && apt-get install -y rapidjson-dev

# Set the working directory
WORKDIR /app

# Copy the source code into the container
COPY upArrow.cpp .

# Compile the C++ code statically to ensure it doesn't depend on runtime libraries
RUN g++ -o upArrow upArrow.cpp -lcurl -ldpp

# Stage 2: Runtime stage
FROM ubuntu:latest

# Copy the static binary from the build stage
COPY --from=build /app/upArrow /upArrow

# Command to run the binary
CMD ["/upArrow"]