# This file is used for:
#   * the source for the image used in the container file (injected in the spec's build)
#   * to get Dependabot to notify about nginx image updates

# This is docker.io/library/nginx:1.29.4-alpine3.23-slim
FROM docker.io/library/nginx@sha256:fc0cff8d49db19250104d2fba8bd1ee3fc2a09ed8163de582804e5d137df7821
