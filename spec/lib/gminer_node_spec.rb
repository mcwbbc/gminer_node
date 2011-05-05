require 'spec_helper'

describe GminerNode do

  before(:each) do
    @mq = mock("message_queue")
    @n = GminerNode.new(@mq)
  end

  describe "publish" do
    it "should publish a message to a queue" do
      queue = mock("queue")
      @mq.should_receive(:queue).with("xqueue").and_return(queue)
      queue.should_receive(:publish).with("message", :persistent => true).and_return(true)
      @n.publish("xqueue", "message")
    end
  end

  describe "process" do
    before(:each) do
      @message = {'worker_key' => '1234', 'job_id' => '12'}
    end

    it "should launch a worker" do
      @message.merge!({'command' => 'launch'})
      JSON.should_receive(:parse).with(@message).and_return(@message)
      @n.should_receive(:launch_processor).and_return(true)
      @n.process(@message)
    end

    it "should shutdown" do
      @message.merge!({'command' => 'shutdown'})
      JSON.should_receive(:parse).with(@message).and_return(@message)
      @n.should_receive(:exit).and_return(true)
      @n.process(@message)
    end
  end

  describe "processor path" do
    it "should return the path for dev" do
      @n.processor_path('development').should == "/workspace/gminer_processor"
    end

    it "should return the path for staging" do
      @n.processor_path('staging').should == "/www/daemons/staging/gminer_processor/current"
    end
  end

  describe "launch processor" do
    it "should launch a processor" do
      Process.should_receive(:fork).and_yield.and_return(123)
      Process.should_receive(:detach).with(123)
      @n.stub!(:processor_path).and_return("path")
      Process.should_receive(:exec).with("path/bin/gminer_processor -e test --config pid_file=path/log/processor-1.pid").and_return(true)
      @n.launch_processor
    end
  end

end
