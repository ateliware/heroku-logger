require 'rails_helper'

RSpec.describe Log, type: :model do
  let(:log) { build(:log) }

  describe "#to_s" do
    it "joins all information in one line" do
      Log.relevant_attributes.each do |attribute|
        next if [:timestamp, :parsing_failure].include?(attribute)
        expect(log.to_s).to include attribute.to_s
        expect(log.to_s).to include log.send(attribute).to_s
      end

      expect(log.to_s).to include log.timestamp.year.to_s
      expect(log.to_s).to include log.timestamp.month.to_s
      expect(log.to_s).to include log.timestamp.day.to_s
    end

    it "order information according to #ordered_attributes" do
      log_attributes = log.to_s.to_enum(:scan, /(\S+)=/).map do
        Regexp.last_match
      end.map { |m| m.to_s.sub('=', '') }

      expect(log_attributes - ['updated_at']).to eq Log.ordered_attributes
    end
  end

  describe "#http_method" do
    it "is always upcased" do
      log.http_method = "put"
      log.save
      expect(log.http_method).to eq log.http_method.upcase
    end
  end
end
