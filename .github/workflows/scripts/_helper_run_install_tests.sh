#!/usr/bin/env sh

# Helper script to set up dependencies for the install tests, then runs the tests.
# Accounts for:
#   * Alpine not having bash nor agent install deps
#   * Amazon Linux not having agent install deps
#   * CentOS 8 being at end-of-life and needing a mirror re-point
#   * Ubuntu not having agent install deps
#
# Note: centos8 can only install Python 3.8, 3.9

# stop on error
set -e

echo "Install solarwinds_apm version: $SOLARWINDS_APM_VERSION"

# setup dependencies quietly
{
    if grep Alpine /etc/os-release; then
        # test deps
        apk add bash && apk --update add ruby ruby-dev build-base

    elif grep Ubuntu /etc/os-release; then
        ubuntu_version=$(grep VERSION_ID /etc/os-release | sed 's/VERSION_ID="//' | sed 's/"//')
        if [ "$ubuntu_version" = "18.04" ] || [ "$ubuntu_version" = "20.04" ]; then
            apt update && apt install -y ruby ruby-dev build-essential
        else
            echo "ERROR: Testing on Ubuntu <18.04 not supported."
            exit 1
        fi
    elif  grep Debian /etc/os-release; then
        debain_version=$(grep VERSION_ID /etc/os-release | sed 's/VERSION_ID="//' | sed 's/"//')
        if [ "$debain_version" = "11" ] || [ "$debain_version" = "12" ]; then
            apt update && apt install -y ruby ruby-dev build-essential
        else
            echo "ERROR: Testing on Debian < 11 not supported."
            exit 1
        fi
    elif  grep rhel /etc/os-release; then
        debain_version=$(grep VERSION_ID /etc/os-release | sed 's/VERSION_ID="//' | sed 's/"//')
        if [ "$debain_version" = "11" ] || [ "$debain_version" = "12" ]; then
            yum update -y && yum install -y ruby ruby-devel gcc gcc-c++ make libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool
            dnf install redhat-rpm-config
            
            git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
                 && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
                 && git clone https://github.com/rbenv/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems \
                 && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile \
                 && echo 'eval "$(rbenv init -)"' >> ~/.profile \
                 && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
                 && echo 'bundler' > ~/.rbenv/default-gems

            echo 'alias be="bundle exec"' >> ~/.bashrc
            echo 'alias be="bundle exec"' >> ~/.profile

            # install rubies to build our gem against
            . ~/.profile \
                && cd /root/.rbenv/plugins/ruby-build && git pull && cd - \
                && rbenv install 2.5.9 \
                && rbenv install 2.6.9 \
                && rbenv install 2.7.5 \
                && rbenv install 3.0.3 \
                && rbenv install 3.1.0

            rbenv local 3.1.0
            # this works for "docker run -it --rm --platform=linux/amd64 --name sample-redhat redhat/ubi8:latest"
        else
            echo "ERROR: Testing on Debian < 11 not supported."
            exit 1
        fi
    fi
} >/dev/null

if [ "$MODE" = "RubyGem" ]; then
    echo "RubyGem"
    gem install solarwinds_apm -v "$SOLARWINDS_APM_VERSION"
elif [ "$MODE" = "packagecloud" ]; then
    echo "packagecloud"
    gem install solarwinds_apm -v "$SOLARWINDS_APM_VERSION" --source https://packagecloud.io/solarwinds/solarwinds-apm-ruby/
fi

if [ "$ARCHITECTURE" = "AMD" ]; then
    echo "AMD"
    ruby ./scripts/test_install.rb
elif [ "$ARCHITECTURE" = "ARM" ]; then
    echo "ARM"
    ruby ./.github/workflows/scripts/test_install.rb
fi







