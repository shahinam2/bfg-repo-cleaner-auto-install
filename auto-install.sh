#!/bin/bash

# URL of the HTML page
html_page_url="https://rtyley.github.io/bfg-repo-cleaner/"

# Fetch the HTML content
html_content=$(curl -s "$html_page_url")

# Extract the latest version and construct the JAR file URL
jar_url=$(echo "$html_content" | grep -oP 'https://repo1\.maven\.org/maven2/com/madgag/bfg/[0-9\.]+/bfg-[0-9\.]+\.jar' | sort -Vr | head -1)

# Download the JAR file if the URL is found
if [ -n "$jar_url" ]; then
    echo "Downloading the latest version from $jar_url..."
    curl -O "$jar_url"
    echo "Download completed."
else
    echo "JAR file URL not found in the HTML page."
fi

# Download and install java 21 LTS if its not already installed

# Define the minimum required Java version
required_version="1.8"

# Update the package list
echo "Updating package list..."
sudo apt update -y

# Check if Java is already installed
if java -version &>/dev/null; then
    echo "Java is already installed."
    # Extract the installed version
    java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo "Installed Java version: $java_version"

    # Check if the installed version is sufficient
    if [[ "$java_version" < "$required_version" ]]; then
        echo "Installed Java version is outdated. Installing Java 21 (LTS)."
    else
        echo "Java version is sufficient for BFG Repo-Cleaner."
        exit 0
    fi
else
    echo "Java is not installed. Installing Java 21 (LTS)."
fi

# Add repository for Java 21 (if not already added)
if ! sudo add-apt-repository -y ppa:openjdk-r/ppa &>/dev/null; then
    echo "Adding repository for OpenJDK 21..."
    sudo add-apt-repository -y ppa:openjdk-r/ppa
fi

# Install OpenJDK 21
echo "Installing OpenJDK 21..."
sudo apt update -y
sudo apt install -y openjdk-21-jdk

# Verify the installation
if java -version &>/dev/null; then
    echo "Java successfully installed."
    java -version
else
    echo "Failed to install Java."
    exit 1
fi
