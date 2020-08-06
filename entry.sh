#!/bin/sh

set -e

service cron start
service cron status

exec "$@"