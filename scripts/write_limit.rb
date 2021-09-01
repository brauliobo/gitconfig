#!/usr/bin/env ruby

require 'pp'

devices = `blkid`.split("\n")
devices = devices.each.with_object({}) do |d,h|
  dev, params = d.split ":", 2
  dev.gsub! '/dev/', ''
  params = Hash[params.scan /\s+([^=]+)="([^"]+)"/]

  h[dev] = params
end

mmmap = Dir.glob('/sys/dev/block/*/uevent').each.with_object({}) do |uevent,h|
  uevent = File.read uevent
  uevent.gsub! "\n", ' '
  params = Hash[uevent.scan /([^=]+)=([^ ]+) /]

  h[params['DEVNAME']] = "#{params['MAJOR']}:#{params['MINOR']}"
end

WR_SPEED = 20_048_576
LABEL_PREFIX = 'chia_'

devices.select!{ |d,p| p['LABEL']&.start_with? LABEL_PREFIX }
# partitions don't work, only block devices
devices.transform_keys!{ |d,p| d[0..-2] }

limits = devices.map do |d,p|
  mm = mmmap[d]
  "#{mm} wbps=#{WR_SPEED}"
end.join '\n'

puts limits
#File.write '/sys/fs/cgroup/system.slice/io.max', "#{limits}\n"
system "echo -e \"#{limits}\" > /sys/fs/cgroup/system.slice/io.max"


