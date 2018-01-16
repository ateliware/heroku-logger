require 'rails_helper'

RSpec.describe LogsController, type: :controller do

  describe "POST #create" do

    describe "persists log" do

      it "when has request information", elasticsearch: true do
        logs = Log.count
        post :create, FactoryBot.build(:log_parser).raw_log
        Log.refresh_index!
        expect(Log.count).to be > logs
        expect(Log.all.last.request_id).to eq('3a42372d-7a30-425d-9e84-b91a56caaf13')
      end

      it "when has arbitrary format", elasticsearch: true do
        logs = Log.count
        post :create, 'some raw log with no request info'
        Log.refresh_index!
        expect(Log.count).to be > logs
        log = Log.all.sort { |x,y| x.timestamp <=> y.timestamp }.last
        expect(log.request_id).to be_nil
        expect(log.raw).to be_present
      end
    end

    xit "authentication" do
      raise Exception.new('Not implemented yet')
    end
  end
end
