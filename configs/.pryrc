Pry.config.exception_handler = proc do |output, exception, _pry_|
  _pry_.run_command 'cat --ex'
  _pry_.run_command 'wtf?'
end
