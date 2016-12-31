require 'spec_helper'

describe Middleman::Cli::KeyCDN::Invalidate do

  let(:cdn) { described_class.new }
  let(:zone) { 'zone123' }
  let(:base_url) { 'example.com' }
  let(:options) do
    config = Middleman::Configuration::ConfigurationManager.new
    config.api_key = 'api123'
    config.zone_id = zone
    config.base_url = base_url
    config.purge_all = true
    config.filter = /.html$/i  # default is /.*/
    config.after_build = true  # default is false
    config
  end
  let(:success) do { status: 'success', description: 'ok' } end
  let(:purge_all_cmd) { "zones/purge/#{zone}.json" }
  let(:purge_urls_cmd) { "zones/purgeurl/#{zone}.json" }

  context 'purge all' do
    it 'purge the zone' do
      allow(cdn).to receive(:list_files).and_return([])
      expect_any_instance_of(KeyCDN::Client).to receive(:get).with(purge_all_cmd).and_return(success)
      cdn.invalidate(options)
    end
  end

  context 'purge urls' do
    before(:each) { options.purge_all = false }
    it 'normalizes paths' do
      files = %w(file directory/index.html)
      normalized_files = %w(/file /directory/index.html /directory/)
      allow(cdn).to receive(:list_files).and_return(files)
      urls = {
        'urls[0]' => 'example.com/file',
        'urls[1]' => 'example.com/directory/index.html',
        'urls[2]' => 'example.com/directory/',
      }
      expect_any_instance_of(KeyCDN::Client).to receive(:del).with(purge_urls_cmd, urls).and_return(success)
      cdn.invalidate(options)
    end

    context 'when files to invalidate are explicitly specified' do
      it 'uses them instead of the files in the build directory' do
        files = (1..3).map { |i| "/file_#{i}" }
        urls = {
          'urls[0]' => 'example.com/file_1',
          'urls[1]' => 'example.com/file_2',
          'urls[2]' => 'example.com/file_3',
        }
        expect_any_instance_of(KeyCDN::Client).to receive(:del).with(purge_urls_cmd, urls).and_return(success)
        cdn.invalidate(options, files)
      end

      it "doesn't filter them" do
        files = (1..3).map { |i| "/file_#{i}" }
        options.filter = /filter that matches no files/
        urls = {
          'urls[0]' => 'example.com/file_1',
          'urls[1]' => 'example.com/file_2',
          'urls[2]' => 'example.com/file_3',
        }
        expect_any_instance_of(KeyCDN::Client).to receive(:del).with(purge_urls_cmd, urls).and_return(success)
        cdn.invalidate(options, files)
      end

      it 'normalizes them' do
        files = %w(file directory/index.html)
        normalized_files = %w(/file /directory/index.html /directory/)
        urls = {
          'urls[0]' => 'example.com/file',
          'urls[1]' => 'example.com/directory/index.html',
          'urls[2]' => 'example.com/directory/',
        }
        expect_any_instance_of(KeyCDN::Client).to receive(:del).with(purge_urls_cmd, urls).and_return(success)
        cdn.invalidate(options, files)
      end
    end

  end
end
