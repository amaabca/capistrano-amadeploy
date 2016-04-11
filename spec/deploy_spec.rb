require 'spec_helper'

describe 'deploy' do
  before do
    mock_config do
      use_recipes :git, :rails
      set :deploy_to, '/foo/bar'
    end
  end

  it 'returns used recipes' do
    expect(config.used_recipes).to eq [:git, :rails]
  end

  it 'checks if recipe is used' do
    expect(config.used_recipes).to include :git
    expect(config.used_recipes).to_not include :bundle
  end

  it 'uses recipe once' do
    config.use_recipe :git
    expect(config.used_recipes).to eq [:git, :rails]
  end

  it 'aborts when recipe name misspelled' do
    with_stderr do |output|
      expect { config.use_recipe(:rvn) }.to raise_error(SystemExit)
      expect(output).to include "Have you misspelled `rvn` recipe name?\n"
    end
  end

  describe 'deploy' do
    it 'runs update and restart' do
      cli_execute 'deploy'
      expect(config).to have_executed('deploy:update', 'deploy:migrate', 'deploy:restart')
    end
  end
end
