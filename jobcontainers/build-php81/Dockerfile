# FROM php:8.1-cli is used to build the image
FROM php:8.1-cli

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     git unzip zip \
#     && rm -rf /var/lib/apt/lists/*
# git - The distributed version control system
# unzip - Unarchiver for ZIP files
# zip - Archiver for ZIP files

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip zip \
    && rm -rf /var/lib/apt/lists/*

# COPY --from=composer:latest /usr/bin/composer /usr/bin/composer is used to copy the composer executable from the composer:latest image to the current image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory to /workspace
WORKDIR /workspace
