require "rails/dairylog/version"

module Rails
  module Dairylog
    class Engine < ::Rails::Engine
      config.to_prepare do
        Rails.logger.formatter = Rails::Dairylog::CowLoggerFormatter.nerw
      end
    end

    class CowLoggerFormatter < ActiveSupport::Logger::SimpleFormatter
      include ActiveSupport::TaggedLogging::Formatter
      def initialize
        super
        if system("which cowsay &>/dev/null")
          @sayer = `which cowsay`.chomp + ' -W 9001'
        end
      end
      def call(severity, time, progname, msg)
        if @sayer && msg.present?
          emsg = escape_for_shell msg
          cmsg = "\n" + `#{@sayer} "#{emsg}"`
          super severity, time, progname, cmsg
        else
          super
        end
      end

      def escape_for_shell(str)
        str.gsub('"', '\\"').strip
      end
    end
  end
end
