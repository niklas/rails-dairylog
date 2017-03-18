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
          @moo_factor = (ENV.fetch('MOO_FACTOR') { 1 }).to_i
          raise("cannot MOO #{@moo_factor} times") unless @moo_factor > 0
        end
      end
      def call(severity, time, progname, msg)
        if @sayer && msg.present?
          super severity, time, progname, gossip(msg, 1 + rand(@moo_factor))
        else
          super
        end
      end

      def gossip(str, moo)
        if moo == 1
          cowsay(str)
        else
          gossip(cowsay(str), moo-1)
        end
      end

      def cowsay(str)
        res, _ok = Open3.capture2(@sayer, stdin_data: str)
        res
      end
    end
  end
end
