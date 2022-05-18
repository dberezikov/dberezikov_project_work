FROM fluent/fluentd

ADD . /fluentd/etc

RUN apk add --no-cache sudo curl build-base ruby-dev \
    && gem install \
        fluent-plugin-elasticsearch \
        fluent-plugin-rewrite-tag-filter \
        fluent-plugin-grok-parser \
    && gem sources --clear-all \
    && rm -rf /home/fluent/.gem/ruby/2.4.0/cache/*.gem
