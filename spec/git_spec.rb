require 'spec_helper'

describe 'git' do
  before do
    mock_config do
      use_recipe :git
      set :deploy_to, '/foo/bar'
    end

    ENV.delete('COMMIT')
  end

  it 'has branch' do
    expect(config.branch).to eq 'master'
  end

  context 'with repository' do
    before do
      mock_config { set :repository, 'git@example.com/test-app.git' }
    end

    it 'sets application from repo' do
      expect(config.application).to eq 'test-app'
    end

    describe 'deploy:setup' do
      it 'clones repository' do
        cli_execute 'deploy:setup'
        expect(config).to have_run('mkdir -p `dirname /foo/bar` && git clone --no-checkout git@example.com/test-app.git /foo/bar')
      end
    end

    describe 'deploy:update' do
      it 'updates' do
        cli_execute 'deploy:update'
        expect(config).to have_run('cd /foo/bar && git fetch origin && git reset --hard origin/master')
      end

      it 'updates submodules' do
        mock_config { set :enable_submodules, true }
        cli_execute 'deploy:update'
        expect(config).to have_run('cd /foo/bar && git fetch origin && git reset --hard origin/master && git submodule init && git submodule -q sync && git submodule -q update')
      end

      it 'updates to specific commit' do
        cli_execute 'deploy:update', 'COMMIT=foobarbaz'
        expect(config).to have_run('cd /foo/bar && git fetch origin && git reset --hard foobarbaz')
      end
    end
  end

  it 'has current revision' do
    expect(config).to receive(:capture).with('cd /foo/bar && git rev-parse HEAD') {"baz\n"}
    expect(config.current_revision).to eq 'baz'
  end

  it 'shows pending' do
    expect(config).to receive(:current_revision) { 'baz' }
    expect(config.namespaces[:deploy]).to receive(:system).with('git log --pretty=medium --stat baz..origin/master')
    cli_execute 'deploy:pending'
  end

  it 'shows pending against specific commit' do
    expect(config).to receive(:current_revision) { 'baz' }
    expect(config.namespaces[:deploy]).to receive(:system).with('git log --pretty=medium --stat baz..foobarbaz')
    cli_execute 'deploy:pending', 'COMMIT=foobarbaz'
  end

  it 'sets forward agent' do
    expect(config.ssh_options[:forward_agent]).to be true
  end
end
