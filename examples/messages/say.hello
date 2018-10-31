#!/usr/bin/env bash

read -r -d '' MESSAGE << EOM
{
  "properties":{},
  "routing_key":"say.hello",
  "payload": "ignored",
  "payload_encoding": "string"
}
EOM

curl -i -XPOST -d"${MESSAGE}" http://guest:guest@localhost:15672/api/exchanges/%2f/amq.topic/publish
