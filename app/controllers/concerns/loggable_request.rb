# app/controllers/concerns/loggable_request.rb
module LoggableRequest
  extend ActiveSupport::Concern

  included do
    before_action :__loggable_request_start_timer
    after_action :log_request_to_db
  end

  private

  def __loggable_request_start_timer
    request.env["loggable_request.started_at_ms"] =
      Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
  end

  def log_request_to_db
    started = request.env["loggable_request.started_at_ms"]
    finished = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
    duration_ms = started ? (finished - started).to_i : nil

    RequestLog.create!(
      method: request.method,
      path: request.fullpath,
      controller: controller_name,
      action: action_name,
      status: response.status,
      duration_ms:   duration_ms,
      params: request.filtered_parameters.except(:controller, :action),
      ip: request.remote_ip,
      user_id: current_api_user&.id,
      model_touched: ApplicationRecord.descendants.map(&:name).join(", ")
    )
  rescue => e
    Rails.logger.error("[LOG ERROR] #{e.class}: #{e.message}")
  end
end
