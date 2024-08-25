FROM ruby:3.3-alpine3.20
ARG PROJECT_TAG
LABEL project=$PROJECT_TAG
ENV WORKSPACE /monadic
WORKDIR $WORKSPACE
ADD Gemfile $WORKSPACE

RUN apk update && \
    apk upgrade && \
    apk add --no-cache linux-headers libxml2-dev make gcc libc-dev bash && \
    apk add --no-cache librsvg librsvg-dev imagemagick imagemagick-dev xz-dev libbz2 && \
    apk add --no-cache gobject-introspection gobject-introspection-dev && \
    apk add --no-cache -t .build-packages --no-cache build-base curl-dev wget gcompat && \
    bundle install -j4

RUN mkdir -p /usr/share/fonts/syntree
COPY fonts/* /usr/share/fonts/syntree/
RUN fc-cache -fv
CMD ["/bin/bash"]
