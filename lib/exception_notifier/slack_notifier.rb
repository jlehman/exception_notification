module ExceptionNotifier
  class SlackNotifier

    attr_accessor :notifier

    def initialize(options)
      begin
        @slack_options = options
        webhook_url = options.fetch(:webhook_url)
        @message_opts = options.fetch(:additional_parameters, {})
        @notifier = Slack::Notifier.new webhook_url, options
      rescue
        @notifier = nil
      end
    end

    def call(exception, options={})
      
      title = "#{exception.message}"
      
      message = "- - - - - - - - - - - -\n"
      message += "*Environment:* #{Rails.env}\n"
      message += "*Time:* #{Time.now.in_time_zone(ActiveSupport::TimeZone.new('Central Time (US & Canada)')).strftime('%m/%d/%Y at %I:%M %p CST')}\n"
      message += "*Exception:* `#{exception.message}`\n"
      message += "\n"
      message += "*Backtrace*: \n"
      exception.backtrace.each_with_index do |bt, i|
        val = bt.gsub("`", "'")
        message += "#{val}\n"
        break if i > 4
      end
      #message += "#{exception.backtrace.first}"
      
      notifier = Slack::Notifier.new @slack_options.fetch(:webhook_url),
                                     channel: @slack_options.fetch(:channel),
                                     username: @slack_options.fetch(:username),
                                     icon_emoji: @slack_options.fetch(:icon_emoji),
                                     attachments: [{
                                       color: @slack_options.fetch(:color),
                                       title: title,
                                       text: message,
                                       mrkdwn_in: %w(text title fallback)
                                     }]
                                     
      #notifier.ping(message, @message_opts) if valid?
      notifier.ping ''
    end
    
    protected

    def valid?
      !@notifier.nil?
    end
  end
end
