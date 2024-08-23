# Use the official Dart SDK image as the base image
FROM dart:stable AS build

# Set the working directory in the container
WORKDIR /app

# Copy the pubspec files to the working directory
COPY pubspec.* ./

# Get the dependencies
RUN dart pub get

# Copy the rest of the application code
COPY . .

# Compile the Dart code to native code
RUN dart compile exe bin/server.dart -o bin/server

# Use a smaller base image for the final stage
FROM debian:buster-slim

# Set the working directory in the container
WORKDIR /app

# Copy the compiled binary from the build stage
COPY --from=build /app/bin/server /app/bin/server

# Expose the port your application runs on
EXPOSE 8080

# Run the compiled binary
CMD ["/app/bin/server"]