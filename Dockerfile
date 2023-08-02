FROM --platform=aarch64 julia:1.9-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
  && apt upgrade --yes

WORKDIR /app

COPY . .

CMD ["/app/entrypoint.sh"]

EXPOSE 8000/tcp
