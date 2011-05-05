# Your starting point for daemon specific classes. This directory is
# already included in your load path, so no need to specify it.
class GminerNode

  NODE_QUEUE_NAME = "gminer-node"

  attr_accessor :mq

  def initialize(mq)
    @processor_id = 0
    @mq = mq
  end

  def publish(name, msg)
    mq.queue(name).publish(msg, :persistent => true)
  end

  def process(msg)
    message = JSON.parse(msg)
    case message['command']
      when 'launch'
        launch_processor
      when 'shutdown'
        exit
    end
  end

  def processor_path(env=DAEMON_ENV)
    hash = {'development' => "/workspace/gminer_processor",
            'staging' => "/www/daemons/staging/gminer_processor/current",
            'processing' => "/www/daemons/processing/gminer_processor/current",
            'production' => "/www/daemons/gminer_processor/current"
          }
    hash[env]
  end

  def launch_processor
    @processor_id += 1
    DaemonKit.logger.debug("Launching Processor: #{@processor_id}")
    DaemonKit.logger.debug("#{processor_path}/bin/gminer_processor -e #{DAEMON_ENV} --config pid_file=#{processor_path}/log/processor-#{@processor_id}.pid")
    # launch a processor
    pid = Process.fork do
      Process.exec("#{processor_path}/bin/gminer_processor -e #{DAEMON_ENV} --config pid_file=#{processor_path}/log/processor-#{@processor_id}.pid")
    end
    Process.detach(pid)
  end

end