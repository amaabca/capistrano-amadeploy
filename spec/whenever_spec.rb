require 'spec_helper'

describe 'whenever' do
  before do
    mock_config { use_recipe :whenever}
  end

  describe 'whenever_identifier' do
    before do
      mock_config { set :application, 'foo' }
    end

    it 'defaults to application' do
      expect(config.whenever_identifier).to eq 'foo'
    end

    it 'default to application with stage when using multistage' do
      mock_config do
        use_recipe :multistage
        set :current_stage, 'bar'
      end
      expect(config.whenever_identifier).to eq 'foo_bar'
    end
  end

  describe 'whenever_cmd' do
    it 'has default value' do
      config.whenever_cmd.should == 'whenever'
      expect(config.whenever_cmd).to eq 'whenever'
    end

    it 'respects bundle recipe' do
      mock_config { use_recipe :bundle }
      expect(config.whenever_cmd).to eq 'bundle exec whenever'
    end
  end

  describe 'whenever:update_crontab' do
    it 'runs command' do
      mock_config do
        set :deploy_to, '/foo/bar'
        set :whenever_cmd, 'wc'
        set :whenever_identifier, 'wi'
      end
      cli_execute 'whenever:update_crontab'
      config.should have_run('cd /foo/bar && wc --update-crontab wi')
    end
  end
end
