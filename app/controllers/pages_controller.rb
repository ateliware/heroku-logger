class PagesController < ApplicationController

  before_action :force_authentication
  before_action :set_query_params
  before_action :set_anchor_logs
  before_action :set_per_page
  before_action :set_date_filters

  def index
    @logs = Log::Searcher.search(
      @query_params, before_log: @before_log, after_log: @after_log,
      per_page: @per_page, from: @from, to: @to, expanding: params[:expand]
    )

    @current = params[:current]

    respond_to do |format|
      format.html
      format.js
    end
  end


  private

  def set_anchor_logs
    if params[:before_log].present?
      @before_log = Log.find(params[:before_log])
    end

    if params[:after_log].present?
      @after_log = Log.find(params[:after_log])
    end
  end

  def set_query_params
    if params[:query].blank?
      @query_params = {}
      return
    end

    parser = Log::Parser.new(params[:query])
    @query_params = parser.attributes
    @query_params[:http_method] = @query_params[:method]
    @query_params[:method] = nil
    @query = parser.raw_log
  end

  def set_per_page
    @per_page = (params[:per_page] || Kaminari.config.default_per_page).to_i
  end

  def set_date_filters
    offset_to_utc = Time.current.utc_offset/3600

    if params[:from].present?
      @from = DateTime.parse(params[:from]).change(:offset => "#{offset_to_utc}00")
    end

    if params[:to].present?
      @to = DateTime.parse(params[:to]).change(:offset => "#{offset_to_utc}00")
    end
  end
end
