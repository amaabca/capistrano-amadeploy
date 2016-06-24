module CapistranoDeploy
  module Hipchat
    def self.load_into(configuration)
      configuration.load do
        namespace :hipchat do
          require 'hipchat'

          set(:deployer) { human }

          desc 'Set notification in hipchat for deployment start'
          task :start_msg do
            client = HipChat::Client.new(hipchat_token)
            deploy_text = "#{human} is deploying #{deployment_name} to #{environment_string}."
            client[hipchat_room].send('Deploy', deploy_text, color: 'yellow')
          end

          desc 'Set notification in hipchat for deployment end'
          task :end_msg do
            client = HipChat::Client.new(hipchat_token)
            deploy_text = "#{human} finished deploying #{deployment_name} to #{environment_string}."

            client[hipchat_room].send('Deploy', deploy_text, color: 'green')
          end

          def human
            user = ENV['HIPCHAT_USER'] || fetch(:hipchat_human, %x(git config user.name).chomp)
            user = user || if (u = %x{git config user.name}.strip) != ''
                             u
                           elsif (u = ENV['USER']) != ''
                             u
                           else
                             'Someone'
                           end
            user
          end

          def deployment_name
             if fetch(:branch, nil)
               branch = fetch(:branch)
               name = "#{application_name}/#{branch}"
               name
             else
               application_name
             end
          end

          def application_name
            alt_application_name.nil? ? fetch(:application) : alt_application_name
          end

          def alt_application_name
            fetch(:hipchat_app_name, nil) || fetch(:app_name, nil)
          end

          def environment_string
            if fetch(:current_stage, nil)
              "#{fetch(:current_stage)} (#{environment_name})"
            else
              environment_name
            end
          end

          def environment_name
            fetch(:hipchat_env, fetch(:rack_env, fetch(:rails_env, fetch(:current_stage))))
          end

        end

      end
    end
  end
end