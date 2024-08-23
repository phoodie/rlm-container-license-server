#!/bin/bash
echo "Linus OS Version: "
cat /etc/redhat-release
echo "IP Address: "
hostname -i

#run license server
#/opt/rlm/rlm -iai
/opt/rlm/rlm -iai -c /opt/rlm/license/*
