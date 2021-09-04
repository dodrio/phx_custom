# Dockerfile for Phoenix project.

# > Global args
# https://github.com/moby/moby/issues/37345#issuecomment-400245466

# customizable args
ARG RELEASE_NAME=<%= @project_name %>
ARG PORT=4000
ARG HEALTHCHECK_PATH=/health-check
ARG USER=elixir
ARG VERSION_ELIXIR=1.12.2
ARG VERSION_ERLANG=24.0.6
ARG VERSION_ALPINE=3.14.0

# internal args
ARG MIX_ENV=prod
ARG WORK_DIR=/app
ARG ASSETS_DIR=assets
ARG CONFIG_DIR=config


# > Prepare
FROM hexpm/elixir:$VERSION_ELIXIR-erlang-$VERSION_ERLANG-alpine-$VERSION_ALPINE AS release-assembler

# args
ARG MIX_ENV
ARG WORK_DIR
ARG ASSETS_DIR
ARG CONFIG_DIR

# envs
ENV MIX_ENV $MIX_ENV

# preparation
RUN mkdir -p $WORK_DIR
WORKDIR $WORK_DIR

RUN apk add --no-cache \
  build-base \
  git \
  nodejs \
  npm

# install mix dependencies
RUN mix local.hex --force
RUN mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# install npm dependencies
COPY $ASSETS_DIR/package.json $ASSETS_DIR/
COPY $ASSETS_DIR/package-lock.json $ASSETS_DIR/
RUN npm install --prefix $ASSETS_DIR

# compile mix deps
RUN mkdir -p $CONFIG_DIR
# copy compile-time config files before we compile dependencies to ensure any
# relevant config change will trigger the dependencies to be re-compiled.
COPY $CONFIG_DIR/config.exs $CONFIG_DIR/$MIX_ENV.exs $CONFIG_DIR/
RUN mix deps.compile

# copy source code
COPY assets assets
COPY lib lib
COPY priv priv

# compile application
RUN mix compile

# compile assets
RUN npm run deploy --prefix $ASSETS_DIR
RUN mix phx.digest

# assemble release
# changes to config/runtime.exs don't require recompiling the code
COPY $CONFIG_DIR/runtime.exs $CONFIG_DIR/
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix release


# > Final
FROM alpine:$VERSION_ALPINE

# args
ARG MIX_ENV
ARG WORK_DIR
ARG RELEASE_NAME
ARG PORT
ARG HEALTHCHECK_PATH
ARG USER

# envs
ENV HOME $WORK_DIR
ENV RELEASE_NAME $RELEASE_NAME
ENV PORT $PORT
ENV HEALTHCHECK_PATH $HEALTHCHECK_PATH
ENV USER $USER

# preparation
RUN mkdir -p $WORK_DIR
WORKDIR $WORK_DIR

# creates an unprivileged user
RUN \
  addgroup \
    -g 1000 \
    -S \
    "$USER" \
  && adduser \
     -u 1000 \
     -G "$USER" \
     -h "/home/$USER" \
     -s /bin/sh \
     -D \
     "$USER"

# required by JIT from OTP 24
RUN apk add --no-cache \
  ncurses-libs \
  libgcc libstdc++ \
  openssl \
  curl && \
  update-ca-certificates --fresh

# limit permissions
USER "$USER":"$USER"

# copy release
COPY --from=release-assembler \
  --chown="$USER":"$USER" \
  $WORK_DIR/_build/$MIX_ENV/rel/$RELEASE_NAME ./

# the exec form of ENTRYPOINT doesn't support shell var interpretation.
# I have to copy it to a file with fixed name.
RUN cp bin/$RELEASE_NAME bin/app

# health check
HEALTHCHECK --start-period=30s --interval=5s --timeout=3s --retries=3 \
  CMD curl -o /dev/null -s -f http://localhost:$PORT$HEALTHCHECK_PATH

EXPOSE $PORT

ENTRYPOINT ["bin/app"]

CMD ["start"]
