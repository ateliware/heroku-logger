require 'rails_helper'

RSpec.describe Log::Searcher do
  let(:params) { { http_method: 'GET', status: 200, path: '/teste' } }

  describe "#search" do
    before(:example) do
      build_list(:log, 10).map(&:save)
      Log.refresh_index!
    end

    it "accepts special characters search" do
      log = build(:log, path: '/path').save
      Log.refresh_index!
      logs = Log::Searcher.search path: '/path'
      expect(logs.size).to eq(1)
      expect(logs.first['_id']).to eq(log['_id'])
    end

    it "supports custom number of results per page" do
      random_per_page = rand(10)
      logs = Log::Searcher.search({}, per_page: random_per_page)
      expect(logs.size).to eq(random_per_page)
    end

    it "supports filtering results to before creation of specific log" do
      sample_log = Log.all.sample
      logs = Log::Searcher.search({}, before_log: sample_log)
      logs.each do |log|
        expect(log.timestamp).to be <= sample_log.timestamp
      end
    end

    it "supports exact search" do
      logs = Log::Searcher.search(http_method: 'get')
      if logs.any?
        expect(logs.map(&:http_method).uniq).to eq(['GET'])
      else
        expect(logs.map(&:method).uniq).to eq([])
      end
    end

    it "supports 'pagination' with before_log and filters" do
      logs = Log::Searcher.search({ http_method: 'get' }, per_page: 5);nil
      paginated_logs = Log::Searcher.search({ http_method: 'get' }, per_page: 10, before_log: logs.first)

      paginated_logs_ids = paginated_logs.map(&:id)
      paginated_logs.each do |log|
        expect(log.http_method).to eq 'GET'
      end
      
      logs.each do |log|
        expect(paginated_logs_ids).to include(log.id)
      end
    end
  end

  describe "#query_terms" do
    it "ignores blank values" do
      params[:http_method] = nil

      query_statements = Log::Searcher.query_terms(params)
      attributes = []
      query_statements.each do |statement|
        expect(statement[:term].keys.size).to eq(1)
        key = statement[:term].keys.first
        attributes << key
      end

      present_attributes = params.select { |key, value| value.present? }.keys
      ignored_attributes = params.select { |key, value| value.blank? }.keys

      present_attributes.each do |attribute|
        expect(attributes).to include attribute
      end

      ignored_attributes.each do |attribute|
        expect(attributes).to_not include attribute
      end
    end
  end
end
