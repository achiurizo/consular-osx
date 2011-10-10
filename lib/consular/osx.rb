require 'consular'
require 'appscript'

module Consular
  # Consular Core to interact with Mac OS X Terminal.
  #
  class OSX < Core
    include Appscript

    Consular.add_core self

    # The acceptable options that OSX Terminal will register.
    #
    ALLOWED_OPTIONS = {
      :window => [:bounds, :visible, :miniaturized],
      :tab    => [:settings, :selected]
    } unless defined?(ALLOWED_OPTIONS)

    class << self

      # Checks to see if the current system is on darwin and if
      # $TERM_PROGRAM is set to Apple_Terminal.
      #
      # @api public
      def valid_system?
        (RUBY_PLATFORM.downcase =~ /darwin/) && ENV['TERM_PROGRAM'] == 'Apple_Terminal'
      end

      # Returns name of Core. used in CLI core selection
      #
      # @api public
      def to_s
        "Consular::OSX Mac OSX Terminal"
      end
    end


    # Initializes a reference to the Terminal.app via appscript
    #
    # @param [String] path
    #   path to Termfile.
    #
    # @api public
    def initialize(path)
      super
      @terminal = app('Terminal')
    end

    # Method called by runner to Execute Termfile setup.
    #
    # @api public
    def setup!
      @termfile[:setup].each { |cmd| execute_command(cmd, :in => active_window) }
    end

    # Method called by runner to execute Termfile.
    #
    # @api public
    def process!
      windows = @termfile[:windows]
      default = windows.delete('default')
      execute_window(default, :default => true) unless default[:tabs].empty?
      windows.each_pair { |_, cont| execute_window(cont) }
    end

    # Executes the commands for each designated window.
    # .run_windows will iterate through each of the tabs in
    # sorted order to execute the tabs in the order they were set.
    # The logic follows this:
    #
    #   If the content is for the 'default' window,
    #   then use the current active window and generate the commands.
    #
    #   If the content is for a new window,
    #   then generate a new window and activate the windows.
    #
    #   Otherwise, open a new tab and execute the commands.
    #
    # @param [Hash] content
    #   The hash contents of the window from the Termfile.
    # @param [Hash] options
    #   Addional options to pass. You can use:
    #     :default - Whether this is being run as the default window.
    #
    # @example
    #   @core.execute_window contents, :default => true
    #   @core.execute_window contents, :default => true
    #
    # @api public
    def execute_window(content, options = {})
      window_options = content[:options]
      _contents      = content[:tabs]
      _first_run     = true

      _contents.keys.sort.each do |key|
        _content = _contents[key]
        _options = content[:options]
        _name    = options[:name]

        _tab =
        if _first_run && !options[:default]
          open_window options.merge(window_options)
        else
          key == 'default' ? active_window : open_tab(_options)
        end

        _first_run = false
        commands = prepend_befores _content[:commands], _contents[:befores]
        commands = set_title _name, commands
        commands.each { |cmd| execute_command cmd, :in => _tab }
      end

    end

    # Prepend a title setting command prior to the other commands.
    #
    # @param [String] title
    #   The title to set for the context of the commands.
    # @param [Array<String>] commands
    #   The context of commands to preprend to.
    #
    # @api public
    def set_title(title, commands)
      cmd = "PS1=\"$PS1\\[\\e]2;#{title}\\a\\]\""
      title ? commands.insert(0, cmd) : commands
    end

    # Prepends the :before commands to the current context's
    # commands if it exists.
    #
    # @param [Array<String>] commands
    #   The current tab commands
    # @param [Array<String>] befores
    #   The current window's :befores
    #
    # @return [Array<String>]
    #   The current context commands with the :before commands prepended
    #
    # @api public
    def prepend_befores(commands, befores = nil)
      unless befores.nil? || befores.empty?
        commands.insert(0, befores).flatten! 
      else
        commands
      end
    end

    # Execute the given command in the context of the
    # active window.
    #
    # @param [String] cmd
    #   The command to execute.
    # @param [Hash] options
    #   Additional options to pass into appscript for the context.
    #
    # @example
    #   @osx.execute_command 'ps aux', :in => @tab_object
    #
    # @api public
    def execute_command(cmd, options = {})
      active_window.do_script cmd, options
    end


    # Opens a new tab and return the last instantiated tab(itself).
    #
    # @param [Hash] options
    #   Options to further customize the window. You can use:
    #     :settings -
    #     :selected -
    #
    # @return
    #   Returns a refernce to the last instantiated tab of the
    #   window.
    #
    # @api public
    def open_tab(options = nil)
      open_terminal_with 't', options
    end

    # Opens a new window and returns its
    # last instantiated tab.(The first 'tab' in the window).
    #
    # @param [Hash] options
    #   Options to further customize the window. You can use:
    #     :bound        - Set the bounds of the windows
    #     :visible      - Set whether or not the current window is visible
    #     :miniaturized - Set whether or not the window is minimized
    #
    # @return
    #   Returns a refernce to the last instantiated tab of the
    #   window.
    #
    # @api public
    def open_window(options = nil)
      open_terminal_with 'n', options
    end


    # Sets the options for the windows/tabs. Will filter options
    # based on what options can be set for either windows or tabs.
    #
    # @param [Hash] options
    #   Options to set for the window/tab
    #
    # @api semipublic
    def set_options(options = {})
      # raise NotImplementedError
    end

    # Returns the current terminal process.
    # We need this method to workaround appscript so that we can
    # instantiate new tabs and windows. Otherwise it would have
    # looked something like # window.make(:new => :tab) but that
    # doesn't work.
    #
    # @api semipublic
    def terminal_process
      app('System Events').application_processes['Terminal.app']
    end

    # Returns the last instantiated tab from active window
    #
    # @api semipublic
    def active_tab
      window = active_window
      tabs   = window.tabs if window
      tabs.last.get        if tabs
    end

    # Returns the currently active window by
    # checking to see if it is the :frontmost window.
    #
    # @api semipublic
    def active_window
      windows = @terminal.windows.get
      windows.detect do |window|
        window.properties_.get[:frontmost] rescue false
      end
    end

    private

    # @api private
    def open_terminal_with(key, options = nil)
      terminal_process.keystroke(key, :using => :command_down)
      set_options options
      active_tab
    end

  end
end
