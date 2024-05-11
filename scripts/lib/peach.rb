Thread.report_on_exception = true
Thread.abort_on_exception  = true

module Enumerable

  def peach method = :each, threads: nil, priority: nil, reraise: false, wait: true, &block
    block   ||= -> *args {}
    threads ||= (ENV['THREADS'] || '10').to_i

    return each(&block) if threads == 1

    pool = Concurrent::FixedThreadPool.new threads
    ret  = send method do |*args|
      pool.post do
        Thread.current.priority = priority if priority
        block.call(*args)
      rescue => e
        raise if reraise
        puts "error: #{e.message} \n#{e.backtrace.join "\n"}"
      end
    end

    pool.shutdown
    pool.wait_for_termination if wait

    ret
  end

  def api_peach method = :each, threads: nil, priority: nil, &block
    peach(method,
      threads:  threads || ENV['API_THREADS'] || 3,
      priority: priority,
      &block
    )
  end

  def cpu_peach method = :each, threads: nil, priority: nil, &block
    peach(method,
      threads:  threads || ENV['CPU_THREADS'],
      priority: ENV['CPU_PRIORITY']&.to_i,
      &block
    )
  end

end
