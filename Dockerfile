# This file is (only) used to get Dependabot to notify about nginx image updates

# This is docker.io/_/nginx:stable-alpine3.20-slim
FROM docker.io/_/nginx@sha256:de9d2e4aadb2c80d5dbfe9c3fa9d5d2ae8fe3a88a35dd1926cd59d28cf78bde5

#FROM docker.io/_/nginx@sha256:de9d2e4aadb2c80d5dbfe9c3fa9d5d2ae8fe3a88a35dd1926cd59d28cf78bde5 as first
#FROM docker.io/_/nginx:stable-alpine3.20-slim as second

# This had better not work... 
#FROM ubuntu:24.04
#FROM docker.io/_/ubuntu:24.04
