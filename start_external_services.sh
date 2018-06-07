#!/bin/sh
docker run -p 9200:9200 --rm docker.elastic.co/elasticsearch/elasticsearch:6.2.4 &
