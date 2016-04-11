require 'spec_helper'

describe 'rails' do
  before do
    mock_config do
      use_recipe :rails
      set :deploy_to, '/foo/bar'
    end
  end

  describe 'deploy:migrate' do
    it 'runs rake db:migrate' do
      cli_execute 'deploy:migrate'
      expect(config).to have_run('cd /foo/bar && RAILS_ENV=production rake db:migrate')
    end

    it 'runs bundle exec db:migrate when using with bundle' do
      mock_config { use_recipe :bundle }
      cli_execute 'deploy:migrate'
      expect(config).to have_run('cd /foo/bar && RAILS_ENV=production bundle exec rake db:migrate')
    end
  end

  describe 'deploy:migrations' do
    it 'runs update, migrate and restart' do
      cli_execute 'deploy:migrations'
      expect(config).to have_executed('deploy:update', 'deploy:migrate', 'deploy:restart')
    end
  end

  describe 'deploy:nomigrate' do
    it 'runs update and restart' do
      cli_execute 'deploy:nomigrate'
      expect(config).to have_executed('deploy:update', 'deploy:restart')
    end

    it 'does not run migrate' do
      cli_execute 'deploy:nomigrate'
      expect(config).to_not have_executed('deploy:migrate')
    end
  end
end
