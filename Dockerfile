FROM julia:1.9-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update \
  && apt upgrade --yes

WORKDIR /app

COPY Project.toml .

RUN julia --project -e 'using Pkg; Pkg.instantiate()'

COPY . .

CMD ["julia", "--project", "rest.jl"]

EXPOSE 8000/tcp
