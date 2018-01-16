class Log::Searcher
  def self.search(params, options={})
    per_page = options[:per_page] || Kaminari.config.default_per_page

    logs = Log.search({
      size: per_page,
      query: {
        bool: {
          must:
            query_terms(params) +
            before_log(options[:before_log])
          }
        },
      sort: { timestamp: { order: :desc }}
    })
  end

  def self.before_log(log)
    return [] if log.blank?

    [
      {
        range: {
          timestamp: {
            lte: log.timestamp,
          }
        }
      }
    ]
  end

  def self.query_terms(params)
    params = params.select do |param, value|
      value.present?
    end

    params.map do |param, value|
      { term: { param => value } }
    end
  end
end
