module CapistranoDeploy
  module Hipchat
    def self.load_into(configuration)
      configuration.load do
        namespace :hipchat do
          require 'hipchat'

          set(:deployer) { %x(git config user.name).chomp }
          desc 'Set notification in hipchat for deployment start'
          task :start_msg do
            client = HipChat::Client.new(hipchat_token)
            deploy_text = "#{deployer} is starting deploy of '#{app_name.upcase}' from branch '#{branch.upcase}' to #{current_stage.upcase}"

            client[hipchat_room].send('Deploy', deploy_text, color: 'yellow')
          end

          desc 'Set notification in hipchat for deployment end'
          task :end_msg do
            client = HipChat::Client.new(hipchat_token)
            deploy_text = "#{deployer} completed the deploy of '#{app_name.upcase}' from branch '#{branch.upcase}' to #{current_stage.upcase}"

            client[hipchat_room].send('Deploy', deploy_text, color: 'green')
          end
        end
      end
    end
  end
end