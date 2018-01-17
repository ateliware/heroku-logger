class Log::Parser
  attr_accessor :raw_log

  def initialize(raw_log='')
    @raw_log = raw_log

    attribute_names.each do |name|
      define_singleton_method(name) do
        attribute(name)
      end
    end
  end

  def timestamp
    raw_date = @raw_log.scan(/\S+/)[2]
    date = Time.parse(raw_date).in_time_zone('Brasilia')
  rescue
    Time.current
  end

  def attribute_names
    @raw_log.scan(/ *([a-z]+_*[a-z]*)=\S+ */).flatten
  end

  def attributes
    attributes_hash = {}
    attribute_names.each do |attribute_name|
      attributes_hash[attribute_name] = attribute(attribute_name)
    end
    attributes_hash.symbolize_keys
  end


  private

  def attribute(attribute)
    raw_attribute = raw_attributes.find { |x| x.starts_with?("#{attribute}=") }
    raw_attribute.sub("#{attribute}=", '').gsub('"', '')
  end

  def raw_attributes
    @raw_log.scan(/\S+=\S+/)
  end
end
