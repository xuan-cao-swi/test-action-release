#!/usr/bin/env sh

apt update && apt install build-essential git-core curl zlib1g-dev -y

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
    && cd /root/.rbenv/plugins/ruby-build && git pull && cd - \
    && rbenv install 3.1.0

rbenv local $RUBY_VERSION
gem install solarwinds_apm -v "$SOLARWINDS_APM_VERSION" --source https://packagecloud.io/solarwinds/solarwinds-apm-ruby/