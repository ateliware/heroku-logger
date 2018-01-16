class Log
  require 'elasticsearch/persistence/model'
  include Elasticsearch::Persistence::Model

  if Rails.env.production?
    index_name "minestore_heroku_logs"
  else
    index_name "log_#{Rails.env}"
  end

  attribute :http_method, String
  attribute :request_id, String
  attribute :status, String
  attribute :host, String
  attribute :path, String, mapping: { analyzer: 'special_characters' }
  attribute :fwd, String
  attribute :raw, String
  attribute :timestamp, DateTime

  before_save :capitalize_http_method

  def to_s
    if request_id.blank?
      raw_date = raw.scan(/\S+/)[2]
      return raw if raw_date.blank?
      return raw.sub(raw_date, '')
    end

    self.class.ordered_attributes.map(&:to_sym).map do |attribute|
      value = self.send(attribute).to_s

      "#{attribute}=#{value}"
    end.join(" ")
  end

  def self.ordered_attributes
    %w(timestamp http_method host path status fwd request_id)
  end

  def self.attributes
    self.attribute_set.entries.map(&:name)
  end

  def self.relevant_attributes
    self.attributes - [:created_at, :updated_at, :raw]
  end

  private

  def capitalize_http_method
    self.http_method.try(:upcase!)
  end


  settings analysis: {
    analyzer: {
      special_characters: {
        type: "custom",
        filter: ["lowercase"],
        tokenizer: "whitespace"
      }
    }
  } do
    mappings dynamic: 'false' do
      indexes :path, analyzer: :special_characters
    end
  end
end
