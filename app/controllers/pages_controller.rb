class PagesController < ApplicationController

  before_action :force_authentication
  before_action :set_query_params
  before_action :set_before_log
  before_action :set_per_page

  def index
    @logs = Log::Searcher.search(query_params, before_log: @before_log, per_page: @per_page)

    if query_params.empty?
      @logs = Log::Sorter.sort_by_date(@logs)
    end
  end


  private

  def query_params
    params.permit(:http_method, :request_id, :status, :host, :path, :fwd, :raw)
  end

  def set_before_log
    return if params[:before_log].blank?
    @before_log = Log.find(params[:before_log])
  end

  def set_query_params
    @query_params = query_params
  end

  def set_per_page
    @per_page = (params[:per_page] || Kaminari.config.default_per_page).to_i
  end
end
