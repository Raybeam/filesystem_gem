require 'FilePather'
require 'rails'
module FilePather
  class Railtie < Rails::Railtie
    #railtie_name :my_plugin

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each { |f| load f }
    end
  end
end