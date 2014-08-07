module CapistranoDeploy
  class Utilities
    attr_accessor :environment_file, :temp_folder, :app_name, :environment_repository, :local_files, :current_stage
    
    def initialize(args = {})
      self.environment_file = args.fetch(:environment_file)
      self.temp_folder = args.fetch(:temp_folder)
      self.app_name = args.fetch(:app_name)
      self.environment_repository = args.fetch(:environment_repository)
      self.local_files = args.fetch(:local_files, [])
      self.current_stage = args.fetch(:current_stage)
    end
    
    def fetch_config
      if /^y/i =~ Capistrano::CLI.ui.ask("Do you wish to overwrite your local #{environment_file} file (y/n)? ")
        system "rm -rf #{temp_folder} && git clone -n #{environment_repository} --depth 1 #{temp_folder}"
        system "cd #{temp_folder} && git checkout HEAD #{app_name}/.env.*"
        system "cp #{temp_folder}/#{app_name}/.env.* ."
        system "cp .env.development .env"
        
        self.local_files = Dir.glob("#{temp_folder}/#{app_name}/.env.#{current_stage}", File::FNM_DOTMATCH)
      else
        puts "Environmental files not updated."
      end
    end 
  end
end
