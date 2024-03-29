# Copyright (c) 2021 SolarWinds, LLC.
# All rights reserved.

# Test script used to check if a newly created gem installs and connects to
# the collector
# requires env vars:
# - SW_APM_SERVICE_KEY
# - SW_APM_COLLECTOR (optional if the key is for production)

require 'solarwinds_apm'

sleep 5

puts SolarWindsAPM::Util.build_init_report

SolarWindsAPM::API.report_init

unless SolarWindsAPM::SDK.solarwinds_ready?(20_000)
  puts "aborting!!! Agent not ready after 10 seconds"
  exit false
end

op = lambda { 10.times {[9, 6, 12, 2, 7, 1, 9, 3, 4, 14, 5, 8].sort} }

SolarWindsAPM.support_report

# no profiling yet for NH, but it shouldn't choke on Profiling.run
SolarWindsAPM::Config[:profiling] = :disabled

SolarWindsAPM::SDK.start_trace("ruby_post_release_test") do
  SolarWindsAPM::Profiling.run { op.call } if defined?(SolarWindsAPM::Profiling)
  op.call unless defined?(SolarWindsAPM::Profiling)
  puts "Looks good!"
end
