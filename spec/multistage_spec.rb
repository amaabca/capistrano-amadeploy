require 'spec_helper'

describe 'multistage' do
  before do
    mock_config do
      use_recipes :multistage

      set :default_stage, :development
      stage(:development, :branch => 'develop') { set :foo, 'bar' }
      stage(:production,  :branch => 'master')  { set :foo, 'baz' }
      stage :another_stage, :foo => 'bar'

      task(:example) {}
    end
  end

  it 'uses default stage' do
    cli_execute 'example'
    expect(config.current_stage).to eq 'development'
    expect(config.foo).to eq 'bar'
  end

  it 'aborts when no stage selected' do
    with_stderr do |output|
      config.unset :default_stage
      expect { cli_execute 'example' }.to raise_error(SystemExit)
      expect(output).to include 'No stage specified. Please specify one of: development, production'
    end
  end

  it 'uses specified stage' do
    cli_execute %w[production example]
    expect(config.current_stage).to eq 'production'
    expect(config.foo).to eq 'baz'
  end

  it 'sets variables from options' do
    cli_execute 'another_stage'
    expect(config.foo).to eq 'bar'
  end

  it 'accepts default option' do
    mock_config { stage :to_be_default, :default => true }
    expect(config.default_stage).to eq :to_be_default
  end

  context 'with git' do
    before do
      mock_config { use_recipe :git }
    end

    it 'infers stage using local branch' do
      config.stub(:local_branch) { 'master' }
      cli_execute 'example'
      expect(config.current_stage).to eq 'production'
      expect(config.branch).to eq 'master'
    end

    it 'uses default state when local branch not matches' do
      config.stub(:local_branch) { 'foo' }
      cli_execute 'example'
      expect(config.current_stage).to eq 'development'
      expect(config.branch).to eq 'develop'
    end
  end
end
