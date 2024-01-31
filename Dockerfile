# Use the latest official Rust runtime as a parent image
FROM rust:latest

# Set the current working directory inside the container
WORKDIR /usr/src/wtnmonisell

# Copy the current directory contents into the container at /usr/src/wtnmonisell
COPY . .

# Compile the application in release mode
RUN cargo build --release

# Expose the port the app might use (adjust if needed)
EXPOSE 8080

# Run the application when the container launches
CMD ["/usr/src/wtnmonisell/target/release/wtnmonisell"]
