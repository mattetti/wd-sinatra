namespace :doc do
  desc "Generate documentation for the web services"
  task :services do
    ENV['DONT_CONNECT'] = 'true'
    ENV['DONT_PRINT_ROUTES'] = 'true'
    require 'wd_sinatra/app_loader'
    root = File.expand_path("../..", File.dirname(__FILE__))
    WDSinatra::AppLoader.start(root)
    LOGGER.level = Logger::FATAL

    require 'fileutils'
    destination = File.join(root, 'doc')
    FileUtils.mkdir_p(destination) unless File.exist?(destination)
    copy_assets(destination)
    File.open("#{destination}/index.html", "w"){|f| f << template.result(binding)}
    puts "Documentation available: #{destination}/index.html"
  end

  def template
    file = resources.join 'template.erb'
    ERB.new File.read(file)
  end

  def resources
    require 'pathname'
    @resources ||= Pathname.new(File.join(File.dirname(__FILE__), 'doc_generator'))
  end

  def copy_assets(destination)
    %W{css js images}.each do |asset_type|
      FileUtils.mkdir_p(File.join(destination, asset_type))
    end
    Dir.glob(resources.join("bootstrap", "js", "*.js")).each do |file| 
      FileUtils.cp(file, File.join(destination, 'js'))
    end
    FileUtils.cp(resources.join('bootstrap', 'bootstrap.css'), File.join(destination, 'css'))
  end
end
