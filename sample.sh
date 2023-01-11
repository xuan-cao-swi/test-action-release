#!/usr/bin/env sh

apt update && apt install ruby -y
ruby -v
gem install solarwinds_apm
