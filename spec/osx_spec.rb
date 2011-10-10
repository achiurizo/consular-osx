require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/consular/osx',__FILE__)

describe Consular::OSX do
  before do
    @core = Consular::OSX.new File.expand_path('../fixtures/bar.term', __FILE__)
  end

  it "should have ALLOWED_OPTIONS" do
    options = Consular::OSX::ALLOWED_OPTIONS

    assert_equal [:bounds, :visible, :miniaturized], options[:window]
    assert_equal [:settings, :selected],             options[:tab]
  end

  it "should be added as a core to Consular" do
    assert_includes Consular.cores, Consular::OSX
  end

  it "should set ivars on .initialize" do
    refute_nil @core.instance_variable_get(:@termfile)
    refute_nil @core.instance_variable_get(:@terminal)
  end

  it "should set .set_title" do
    assert_equal ["PS1=\"$PS1\\[\\e]2;hey\\a\\]\"",'ls'], @core.set_title('hey', ['ls'])
    assert_equal ['ls'],                                  @core.set_title(nil,   ['ls'])
  end

  it "should prepend commands with .prepend_befores" do
    assert_equal ['ps', 'ls'], @core.prepend_befores(['ls'], ['ps'])
    assert_equal ['ls'],       @core.prepend_befores(['ls'])
  end

  it "should .execute_command" do
    window = mock()
    window.expects(:do_script).with('ls',{}).returns(true)
    @core.expects(:active_window).returns(window)
    assert @core.execute_command('ls', {}), "that core executes do_script"
  end

  it "should executes setup block with .setup!" do
    @core.termfile[:setup] = ['ls','ls']
    @core.expects(:execute_command).with('ls', anything).twice
    assert @core.setup!
  end

  it "should executes window context with .process!" do
    @core.termfile[:windows] = {
      'default' => { :tabs => {'default' => {:commands => ['ls']}}},
      'window1' => { :tabs => {'default' => {:commands => ['whoami']}}},
      'window2' => { :tabs => {'default' => {:commands => ['whoami']}}},
    }

    @core.expects(:execute_window).with(@core.termfile[:windows]['default'], :default => true).once
    @core.expects(:execute_window).with(@core.termfile[:windows]['window1']).twice
    assert @core.process!
  end

  it "should .open_tab" do
    @core.expects(:open_terminal_with).with('t', nil).returns(true)
    assert @core.open_tab
  end

  it "should .open_window" do
    @core.expects(:open_terminal_with).with('n', nil).returns(true)
    assert @core.open_window
  end

  describe ".execute_window" do
    it "should use the current active window with 'default' window" do
      skip
    end

    it "should use the open a new window if its teh first run and not the 'default' window" do
      skip
    end

    it "should open a new tab if its not the 'default' window" do
      skip
    end
  end


end
