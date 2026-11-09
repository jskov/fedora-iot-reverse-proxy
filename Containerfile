# This file is used for:
#   * the source for the image used in the container file (injected in the spec's build)
#   * to get Dependabot to notify about nginx image updates

# This is docker.io/library/nginx:1.29.4-alpine3.23-slim
FROM docker.io/library/nginx@sha256:165ddde8751e75a1c907d24ef10d9f6deb08b57e0fe56caf67512486aff76d82
