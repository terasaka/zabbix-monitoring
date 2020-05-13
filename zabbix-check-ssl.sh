#!/bin/bash
/usr/lib/zabbix/externalscripts/ssl-cert-check -s $1 -p 443 -n | cut -d "=" -f2