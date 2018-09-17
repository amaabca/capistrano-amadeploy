module CapistranoDeploy
  module SlackNotifications
    def self.load_into(configuration)
      configuration.load do
        namespace :slacknotifications do
          require 'slack-notifier'

          set(:deployer) { %x(git config user.name).chomp }
          set(:elapsed_time) { `ps -p #{$$} -o etime=`.strip }

          desc 'Set notification in slack for deployment start'
          task :start_msg do
            notifier = Slack::Notifier.new slack_webhook_url
            msg = ":eyes: #{app_name.capitalize} Application is Deploying"
            attachments = {
              color: 'warning',
              title: msg,
              fields: [{
                title: 'Environment',
                value: current_stage,
                short: true
              }, {
                title: 'Branch',
                value: branch,
                short: true
              }, {
                title: 'Deployer',
                value: deployer,
                short: true
              }],
              fallback: msg
            }

            notifier.post attachments: [attachments]
          end

          desc 'Set notification in slack for deployment end'
          task :end_msg do
            notifier = Slack::Notifier.new slack_webhook_url
            msg = ":bangbang: #{app_name.capitalize} Application Deployed"
            attachments = {
              color: 'good',
              title: msg,
              fields: [{
                title: 'Environment',
                value: current_stage,
                short: true
              }, {
                title: 'Branch',
                value: branch,
                short: true
              }, {
                title: 'Deployer',
                value: deployer,
                short: true
              }, {
                title: 'Time',
                value: elapsed_time,
                short: true
              }],
              fallback: msg
            }

            notifier.post attachments: [attachments]
          end
        end
      end
    end
  end
end