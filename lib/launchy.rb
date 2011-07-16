require 'uri'

#
# Top level entry point into Launchy. Almost everyone will just use the single
# call:
#
#   Launchy.open( uri, options = {} )
#
# The currently defined global options are:
#
#   :debug        Turn on debugging output
#   :application  Explicitly state what application class is going to be used
#   :host_os      Explicitly state what host operating system to pretend to be
#
# Other options may be used, and those will be passed directly to the
# application class
#
module Launchy

  class << self
    #
    # Convenience method to launch an item
    #
    def open(uri, options = {} )
      begin
        extract_global_options( options )
        uri = URI.parse( uri )
        if app = Launchy::Application.for_scheme( uri ) then
          app.new.open( uri, options )
        else
          msg = "Unable to launch #{uri} with options #{options.inspect}"
          Launchy.log "#{self.name} : #{msg}"
          $stderr.puts msg
        end
      rescue Exception => e
        msg = "Failure in opening #{uri} with options #{options.inspect}: #{e}"
        Launchy.log "#{self.name} : #{msg}"
        $stderr.puts msg
      end
    end

    def reset_global_options
      Launchy.debug       = false
      Launchy.application = nil
      Launchy.host_os     = nil
    end

    def extract_global_options( options )
      Launchy.debug        = options.delete( :debug       ) || ENV['LAUNCHY_DEBUG']
      Launchy.application  = options.delete( :application ) || ENV['LAUNCHY_APPLICATION']
      Launchy.host_os      = options.delete( :host_os     ) || ENV['LAUNCHY_HOST_OS']
    end

    def debug=( d )
      @debug = (d == "true")
    end

    # we may do logging before a call to 'open', hence the need to check
    # LAUNCHY_DEBUG here
    def debug?
      @debug || (ENV['LAUNCHY_DEBUG'] == 'true')
    end

    def application=( app )
      @application = app
    end

    def application
      @application
    end

    def host_os=( host_os )
      @host_os = host_os
    end

    def host_os
      @host_os
    end

    def log(msg)
      $stderr.puts "LAUNCHY_DEBUG: #{msg}" if Launchy.debug?
    end
  end
end

require 'launchy/version'
require 'launchy/cli'
require 'launchy/descendant_tracker'
require 'launchy/error'
require 'launchy/application'
require 'launchy/detect_host_os'
