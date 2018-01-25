class Log::Searcher
  def self.search(params, options={})
    per_page = options[:per_page] || Kaminari.config.default_per_page
    per_page *= 2 if options[:expanding]

    logs = Log.search({
      size: per_page,
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

    return logs unless options[:expanding].present?
    if options[:after_log].present?
      logs.sort { |x,y| x.timestamp <=> y.timestamp }.reverse
    else
      logs.sort { |x,y| x.timestamp <=> y.timestamp }
    end
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

    params.map do |key, value|
      {
        match: {
          key => {
            query: value,
            operator: 'and'
          }
        }
      }
    end
  end

  def self.order(options)
    (options[:after_log].present? && options[:expanding].present?) ? :asc : :desc
  end
end
