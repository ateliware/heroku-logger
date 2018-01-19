class Log::Searcher
  def self.search(params, options={})
    per_page = options[:per_page] || Kaminari.config.default_per_page
    per_page *= 3 if options[:expanding]

    logs = Log.search({
      from: 50, size: per_page,
      query: {
        bool: {
          must:
            query_terms(params) +
            before_log(options[:before_log]) +
            after_log(options[:after_log]) +
            date_filter(options[:from], options[:to])
          }
        },
      sort: { timestamp: { order: order(options) }}
    })

    return logs unless (options[:after_log].present? && options[:expanding].present?)
    logs.sort { |x,y| x.created_at <=> y.created_at }
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

  def self.after_log(log)
    return [] if log.blank?

    [
      {
        range: {
          timestamp: {
            gte: log.timestamp,
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

  def self.order(options)
    (options[:after_log].present? && options[:expanding].present?) ? :asc : :desc
  end
end
