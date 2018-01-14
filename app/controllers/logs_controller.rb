class LogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    parser = Log::Parser.new(request.raw_post)

    if parser.try(:request_id)
      Log.create({
        http_method: parser.method,
        request_id: parser.request_id,
        status: parser.status,
        host: parser.host,
        path: parser.path,
        fwd: parser.fwd,
        timestamp: parser.timestamp,
        raw: request.raw_post
      })
    else
      Log.create raw: request.raw_post
    end

    head :ok
  end
end
