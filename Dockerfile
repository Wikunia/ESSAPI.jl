FROM --platform=aarch64 julia:1.9-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
  && apt upgrade --yes

WORKDIR /app

COPY . .

RUN julia --project -e 'using Pkg; Pkg.instantiate()'

CMD ["julia", "--project", "src/rest.jl"]

EXPOSE 8000/tcp
