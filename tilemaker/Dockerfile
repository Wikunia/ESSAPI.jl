FROM --platform=aarch64 debian:bullseye-slim AS build

LABEL Description="Tilemaker" Version="1.4.0"

ARG DEBIAN_FRONTEND=noninteractive

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      git \
      libboost-filesystem-dev \
      libboost-iostreams-dev \
      libboost-program-options-dev \
      libboost-system-dev \
      liblua5.1-0 \
      liblua5.1-0-dev \
      libprotobuf-dev \
      libshp-dev \
      libsqlite3-dev \
      protobuf-compiler \
      rapidjson-dev \
      shapelib

WORKDIR /code
RUN git clone --depth 1 --branch v2.4.0 https://github.com/systemed/tilemaker.git

RUN cp /code/tilemaker/CMakeLists.txt / \
  && cp -r /code/tilemaker/cmake /cmake \
  && cp -r /code/tilemaker/src /src \
  && cp -r /code/tilemaker/include /include

WORKDIR /build

RUN cmake -DTILEMAKER_BUILD_STATIC=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=g++ ..
RUN cmake --build .
RUN strip tilemaker

FROM --platform=aarch64 debian:bullseye-slim

WORKDIR /

COPY --from=build /build/tilemaker .
COPY --from=build /code/tilemaker/resources resources
COPY --from=build /code/tilemaker/process.lua process.lua
COPY --from=build /code/tilemaker/config.json config.json

ENTRYPOINT ["/tilemaker"]
