#!/usr/bin/env bash

yum update -y && yum install -y ruby-devel git-core gcc gcc-c++ make perl zlib-devel bzip2 openssl-devel
# libyaml-devel libffi-devel openssl-devel make autoconf automake libtool
# yum update -y && yum install -y ruby-devel git-core gcc gcc-c++ make libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool

git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
     && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
     && git clone https://github.com/rbenv/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems \
     && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile \
     && echo 'eval "$(rbenv init -)"' >> ~/.profile \
     && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
     && echo 'bundler' > ~/.rbenv/default-gems

echo 'alias be="bundle exec"' >> ~/.bashrc
echo 'alias be="bundle exec"' >> ~/.profile

. ~/.profile \
    && cd /root/.rbenv/plugins/ruby-build && git pull && cd - 

echo "RUBY VERSION"
echo $RUBY_VERSION
echo "$RUBY_VERSION"
rbenv install $RUBY_VERSION
rbenv global $RUBY_VERSION
rbenv local $RUBY_VERSION
gem install solarwinds_apm -v "$SOLARWINDS_APM_VERSION" --source https://packagecloud.io/solarwinds/solarwinds-apm-ruby/
ruby .github/workflows/scripts/test_install.rb