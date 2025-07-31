# This file is (only) used to get Dependabot to notify about nginx image updates

# Created iot-rpm-build service on https://access.redhat.com/terms-based-registry/accounts
# registry.redhat.io/ubi9/nginx-124 : 341MB

# Docker hub 1.28.0-alpine-slim image: 13MB
# podman pull docker.io/library/nginx@sha256:b08e95f5c81ffce8f64319f7928b555a062c37daa47439dee5f99c62577a8763

# This is docker.io/library/nginx:1.28.0-alpine-slim
FROM docker.io/library/nginx@sha256:d83c0138ea82c9f05c4378a5001e0c71256b647603c10c186bd7697a4db722d3

#FROM docker.io/_/nginx@sha256:de9d2e4aadb2c80d5dbfe9c3fa9d5d2ae8fe3a88a35dd1926cd59d28cf78bde5 as first
#FROM docker.io/_/nginx:stable-alpine3.20-slim as second

# This had better not work...
#FROM ubuntu:24.04
#FROM docker.io/_/ubuntu:24.04
