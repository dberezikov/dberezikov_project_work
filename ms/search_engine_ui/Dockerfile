FROM python:3.9-alpine

RUN mkdir /app

COPY ui /app/ui
COPY gunicornconf.py /app/gunicornconf.py
COPY requirements.txt requirements.txt 

RUN apk --no-cache --update add build-base \
    && pip install --upgrade pip \
    && pip install -r requirements.txt \
    && apk del build-base

WORKDIR /app/ui

ENV FLASK_APP=ui.py

CMD ["gunicorn", "--config", "/app/gunicornconf.py", "ui:app"]
