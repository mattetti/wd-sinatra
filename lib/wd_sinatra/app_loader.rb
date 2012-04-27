if RUBY_VERSION =~ /1.8/
  require 'rubygems'
  require 'backports'
end
require 'bundler'
Bundler.setup
require 'logger'
require 'weasel_diesel'

module WDSinatra
  module AppLoader
    module_function

    # Boot in server mode
    def server(root_path)
      @root = root_path
      unless @booted
        console
        load_apis
        load_middleware
        set_sinatra_routes
        set_sinatra_settings
      end
    end

    # Boot in console mode
    def console(root_path)
      @root = root_path
      unless @booted
        set_env
        load_environment
        set_loadpath
        load_lib_dependencies
        #TODO: datastore_setup
        load_models
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
      require File.join(root_path, 'config', 'app')
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
      # TODO: hook to custom app dependencies
    end

    def load_models
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
      WSList.all.sort.each{|api| api.load_sinatra_route }
    end

    def load_middleware
      require File.join(root_path, 'config', 'middleware')
    end

    def set_sinatra_settings
      # Using the :production env would wrap errors instead of displaying them
      # like in dev mode
      set :environment, RACK_ENV
      set :root, ROOT
      set :app_file, __FILE__
      set :public_folder, File.join(root_path, "public")
      # Checks on static files before dispatching calls
      enable :static
      # enable rack session
      enable :session
      set :raise_errors, false
      # enable that option to run by calling this file automatically (without using the config.ru file)
      # enable :run
      use Rack::ContentLength
    end

  end
end
