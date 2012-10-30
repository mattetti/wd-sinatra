if RUBY_VERSION =~ /1.8/
  require 'rubygems'
  require 'backports'
end
require 'bundler'
Bundler.setup
require 'logger'
require 'weasel_diesel'
require 'wd_sinatra/ws_list_ext'

module WDSinatra
  module AppLoader
    module_function

    # Boot in server mode
    def server(root_path)
      @root = root_path
      unless @booted
        console(root_path)
        load_middleware
        set_sinatra_routes
        set_sinatra_settings
        load_hooks
      end
    end

    # Boot in console mode
    def console(root_path)
      @root = root_path
      unless @booted
        set_env
        set_loadpath
        load_environment
        load_lib_dependencies
        load_app_file
        load_models
        load_apis
        @booted =  true
      end
    end

    def root_path
      @root
    end

    # PRIVATE

    # Sets the environment (RACK_ENV) based on some env variables.
    def set_env
      if !Object.const_defined?(:RACK_ENV)
        ENV['RACK_ENV'] ||= ENV['RAILS_ENV'] || 'development'
        Object.const_set(:RACK_ENV, ENV['RACK_ENV'])
      end
      puts "Running in #{RACK_ENV} mode" if RACK_ENV == 'development'
    end


    # Loads an environment specific config if available, the config file is where the logger should be set
    # if it was not, we are using stdout.
    def load_environment(env=RACK_ENV)
      # Load the default which can be overwritten or extended by specific
      # env config files.
      require File.join(root_path, 'config', 'environments', 'default.rb')
      env_file = File.join(root_path, "config", "environments", "#{env}.rb")
      if File.exist?(env_file)
        require env_file
      else
        debug_msg = "Environment file: #{env_file} couldn't be found, using only the default environment config instead." unless env == 'development'
      end
      # making sure we have a LOGGER constant defined.
      unless Object.const_defined?(:LOGGER)
        Object.const_set(:LOGGER, Logger.new($stdout))
      end
      LOGGER.debug(debug_msg) if debug_msg
    end

    def set_loadpath(root=nil)
      root ||= root_path
      $: << root
      $: << File.join(root, 'lib')
      $: << File.join(root, 'models')
    end

    def load_lib_dependencies
      # WeaselDiesel is the web service DSL gem used to define services.
      require 'weasel_diesel'
      require 'sinatra'
      require 'wd_sinatra/sinatra_ext'
    end

    def load_app_file
      require File.join(root_path, 'lib', 'app')
    end

    def load_models
      return if ENV['DONT_LOAD_MODELS']
      Dir.glob(File.join(root_path, "models", "**", "*.rb")).each do |model|
        require model
      end
    end

    # DSL routes are located in the api folder
    def load_apis
      Dir.glob(File.join(root_path, "api", "**", "*.rb")).each do |api|
        require api
      end
    end

    def set_sinatra_routes
      WSList.sorted_for_sinatra_load.each{|api| api.load_sinatra_route }
    end

    def load_middleware
      require File.join(root_path, 'config', 'middleware')
    end

    def set_sinatra_settings
      require File.join(root_path, 'config', 'sinatra_config')
    end

    def load_hooks
      hooks_file = File.join(root_path, 'lib', 'hooks.rb')
      if File.exist?(hooks_file)
        require 'hooks'
      end
    end

  end
end
