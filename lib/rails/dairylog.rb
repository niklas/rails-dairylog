require "rails/dairylog/version"
require 'open3'

module Rails
  module Dairylog
    class Engine < ::Rails::Engine
      config.to_prepare do
        Rails.logger.formatter = Rails::Dairylog::CowLoggerFormatter.new
      end
    end

    class CowLoggerFormatter < ActiveSupport::Logger::SimpleFormatter
      include ActiveSupport::TaggedLogging::Formatter
      def initialize
        super
        if system("which cowsay &>/dev/null")
          @sayer = `which cowsay`.chomp + ' -n'
        end
      end
      def call(severity, time, progname, msg)
        if @sayer && msg.present?
          super severity, time, progname, cowsay(msg)
        else
          super
        end
      end

      def cowsay(str)
        res, _ok = Open3.capture2(@sayer, stdin_data: str)
        res
      end
    end
  end
end
