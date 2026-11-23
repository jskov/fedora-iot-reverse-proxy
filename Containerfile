# This file is used for:
#   * the source for the image used in the container file (injected in the spec's build)
#   * to get Dependabot to notify about nginx image updates

# This is docker.io/library/nginx:1.29.4-alpine3.23-slim
FROM docker.io/library/nginx@sha256:84f7876d21d154885f99554d7ae325d8c2213f9169726ea7ab60642f2573a787
