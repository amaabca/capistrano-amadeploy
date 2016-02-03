module CapistranoDeploy
  module Aws
    def self.load_into(configuration)
      configuration.load do

        set(:environment_file) { ".env" }
        set(:temp_folder) { "./tmp/env_config" }
        set(:environment_branch) { "master" }

        namespace :aws do
          desc "Push ENV file from local to AWS"
          task :setup do
            require 'capistrano-deploy/utilities'
            utilities = ::CapistranoDeploy::Utilities.new(
              environment_file: environment_file,
              temp_folder: temp_folder,
              app_name: app_name,
              environment_repository: environment_repository,
              current_stage: current_stage,
              environment_branch: environment_branch
            )

            utilities.fetch_config

            utilities.local_files.each do |file|
              msg = "Do you wish to overwrite the #{current_stage} #{environment_file} file with your local version? WARNING: You should have pulled in the latest version locally via the environment:servers:local task (y/n)? "
              if /^y/i =~ Capistrano::CLI.ui.ask(msg)
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
