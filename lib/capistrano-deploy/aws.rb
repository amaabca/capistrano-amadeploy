module CapistranoDeploy
  module Aws
    def self.load_into(configuration)
      configuration.load do

        set(:environment_file) { ".env" }
        set(:temp_folder) { "./tmp/env_config" }
        
        namespace :aws do
          desc "Push ENV file from local to AWS"
          task :setup do
            require 'capistrano-deploy/utilities'
            utilities = ::CapistranoDeploy::Utilities.new(
              environment_file: environment_file, 
              temp_folder: temp_folder, 
              app_name: app_name, 
              environment_repository: environment_repository,
              current_stage: current_stage
            )
            
            utilities.fetch_config

            utilities.local_files.each do |file|
              if /^y/i =~ Capistrano::CLI.ui.ask("Do you wish to override the existing #{environment_file} file (y/n)? ")
                upload file, File.join(deploy_to, environment_file)
              else
                puts "Config not changed"
              end 
            end     
          end
        end
      end
    end
  end
end
