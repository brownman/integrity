#!/usr/bin/env ruby
# Delete old builds
# Put this into the crontab for bonus points
# Based on https://gist.github.com/336330


INTEGRITY_BUILDS_PATH = "/home/integrity/integrity/builds"
KEEP_COUNT = 5

builds = `ls -x #{INTEGRITY_BUILDS_PATH}`.split.sort

if KEEP_COUNT < builds.length
  puts "keeping #{KEEP_COUNT} of #{builds.length} old builds"
  directories = ( builds - builds.last(KEEP_COUNT) ).map { |build| File.join( INTEGRITY_BUILDS_PATH, build ) }.join(" ")
  system( "rm -rf #{directories}" )
else
  puts "No old builds to clean up"
end
