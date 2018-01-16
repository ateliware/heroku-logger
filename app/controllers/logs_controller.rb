class LogsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    request.raw_post.split("\n").each do |request|
      parser = Log::Parser.new(request)

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
        Log.create raw: request.raw_post.force_encoding('UTF-8'), timestamp: parser.timestamp
      end
    end

    head :ok
  end
end
