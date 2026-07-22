FROM php:8.1-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /workspace
