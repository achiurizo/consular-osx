# Consular - OSX Core

Automate your OSX Terminal with Consular


# Setup && Installation

If you haven't already, install Consular:

  gem install consular --pre


next, run `init`:

  consular init

This will generate a global directory and also a `.consularc` in your home
directory. On the top of your `.consularc`, just require this core like
so:

    # You can require your additional core gems here.
    require 'consular/osx'

    # You can set specific Consular configurations
    # here.
    Consular.configure do |c|
    end


Now you can use OSX Terminal to run your Consular scripts!
