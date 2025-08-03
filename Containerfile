# This file is used for:
#   * the source for the image used in the container file (injected in the spec's build)
#   * to get Dependabot to notify about nginx image updates

# This is docker.io/library/nginx:1.28.0-alpine-slim
FROM docker.io/library/nginx@sha256:d83c0138ea82c9f05c4378a5001e0c71256b647603c10c186bd7697a4db722d3
