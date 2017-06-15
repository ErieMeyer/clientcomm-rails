module AnalyticsHelper
  private

  # Send the provided tracking data through to the AnalyticsService
  def analytics_track(label:, data: {})
    # NOTE: May eventually want to diverge distinct and visitor IDs, so
    #       tracking them separately for now.

    tracking_data = data.merge(
      ip: visitor_ip,
      visitor_id: session[:visitor_id]
    )
    user_agent = request.env['HTTP_USER_AGENT']

    AnalyticsService.instance.track(
      distinct_id: distinct_id,
      label: label,
      user_agent: user_agent,
      data: tracking_data
    )
  end

  def visitor_ip
    request.remote_ip || request.env['HTTP_X_FORWARDED_FOR']
  end

  def distinct_id
    distinct = !current_user.nil? ? current_user.id : session[:visitor_id]
    "#{id_prefix}-#{distinct}"
  end

  def id_prefix
    # NOTE: DEPLOY_BASE_URL is set by heroku
    base = request.base_url || ENV['DEPLOY_BASE_URL']
    URI.parse(base).hostname.split(".")[0..1].join("_")
  end
end
