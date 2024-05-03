FROM python:3.9.19-alpine3.19

# In order to install uWSGI, we need some C build dependencies
# Use --virtual so that we can remove them in the final image
RUN apk add --virtual .build-deps \
            --no-cache \
            python3-dev \
            build-base \
            linux-headers \
            pcre-dev

# PCRE dependency will have to stay there even in the final image
RUN apk add --no-cache pcre

# Create permissionless user
RUN addgroup -S app && adduser -S app -G app -h /app

# Install Python libs requirements
WORKDIR /app
USER app
COPY requirements.txt /app
RUN pip install -r /app/requirements.txt

# Remove useless build dependencies
USER root
RUN apk del .build-deps && rm -rf /var/cache/apk/*

# Copy app source
USER app
COPY . /app

EXPOSE 5000
CMD ["/app/.local/bin/uwsgi", "--ini", "/app/wsgi.ini"]