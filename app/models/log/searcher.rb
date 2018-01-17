class Log::Searcher
  def self.search(params, options={})
    per_page = options[:per_page] || Kaminari.config.default_per_page

    Log.search({
      size: per_page,
      query: {
        bool: {
          must:
            query_terms(params) +
            before_log(options[:before_log]) +
            date_filter(options[:from], options[:to])
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

  def self.date_filter(from, to)
    return [] if from.blank? && to.blank?

    [
      {
        range: {
          timestamp: {
            gte: from,
            lte: to
          }
        }
      }
    ]
  end

  def self.query_terms(params)
    params = params.select do |param, value|
      value.present?
    end

    es_params = params.map do |param, value|
      { term: { param => value } }
    end

    es_params = handle_special_host(es_params, params)
  end

  def self.handle_special_host(es_params, params)
    return es_params unless params[:host].try(:include?, '-')

    es_params -= [{ term: { host: params[:host] } }]
    es_params += [{ term: { host: params[:host].split('-')[0] } }]
    es_params += [{ term: { host: params[:host].split('-')[1] } }]
    es_params
  end
end
