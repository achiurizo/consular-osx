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

end
