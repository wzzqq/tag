FROM python:3.7.15-slim as base

# Create app directory
WORKDIR /app


RUN apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install \
    --no-install-recommends --yes \
    build-essential libpq-dev cron git libopenblas-dev liblapack-dev libatlas-base-dev libblas-dev gfortran zlib1g-dev cmake pkg-config \
     --yes  && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM base as build

COPY requirements.txt .

RUN mkdir /install    && \
    pip download --destination-directory /install -r /app/requirements.txt

#RUN pip download --destination-directory /install -r /app/requirements.txt

FROM python:3.7.15-slim  as release

RUN apt-get update && apt-get -y install libxml2-dev libxslt-dev zlib1g-dev cmake pkg-config cron git gcc  build-essential libpq-dev cron git libopenblas-dev liblapack-dev libatlas-base-dev libblas-dev gfortran
#RUN apt-get install -y libxml2-dev libxslt-dev zlib1g-dev libopenblas-dev cmake pkg-config  && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY --from=build /install /install

COPY requirements.txt .

RUN pip install --no-index --find-links=/install -r requirements.txt   && \
    mkdir /app/docker

#RUN mkdir /app/docker

COPY docker/entry.sh /app/docker/

RUN touch /var/log/bustag.log && \
    rm -rf /install &&  rm -rf /root/.cache/pip && \
    chmod 755 /app/docker/*.sh

#RUN rm -rf /install &&  rm -rf /root/.cache/pip

#RUN chmod 755 /app/docker/*.sh

EXPOSE 8000

CMD ["/app/docker/entry.sh"]
