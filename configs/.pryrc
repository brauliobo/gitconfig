Pry.config.exception_handler = proc do |output, exception, _pry_|
  local_index = nil
  local_line = nil
  exception.backtrace.each_with_index do |l, i|
    next unless l =~ /([^:]+):(.+)/
    file = $1
    source_path = defined?(Rails) ? Rails.root.to_s : Dir.pwd 
    if file.starts_with? source_path  
      local_index = i
      local_line = l
      break
    end
  end

  _pry_.run_command 'wtf?'
  _pry_.run_command "cat --ex #{local_index}"
  puts exception.message
  puts local_line
end
