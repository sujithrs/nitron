require 'nitron/version'

unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  
  Dir.glob(File.join(File.dirname(__FILE__), "nitron/**/*.rb")).each do |file|
    app.files.unshift(file)
  end

  Dir[File.join(File.dirname(__FILE__), 'nitron/coredata/model/**/*.rb')].each { |file| app.files.unshift(file) }
  Dir[File.join(File.dirname(__FILE__), 'nitron/coredata/relation/**/*.rb')].each { |file| app.files.unshift(file) }

  app.files.unshift(File.join(File.dirname(__FILE__), 'nitron/extensions/view_controller.rb'))

  unless app.frameworks.include?("CoreData")
    app.frameworks << "CoreData"
  end
end
