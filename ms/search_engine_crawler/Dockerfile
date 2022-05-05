FROM python:3.9-alpine

RUN mkdir /app

COPY crawler /app/crawler 
COPY requirements.txt requirements.txt

RUN apk --no-cache --update add build-base \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \   
    && apk del build-base 

WORKDIR /app

ENV EXCLUDE_URLS='.*github.com'

CMD [ "python3", "-u", "crawler/crawler.py", "https://vitkhab.github.io/search_engine_test_site/" ]
