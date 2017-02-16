require 'date'
require 'grokngelf/importers/syslog'

module GrokNGelf
  module Commands
    class SyslogCommand < GrokNGelf::Commands::AbstractCommand

      parameter "LOG_FILE", "file containing the logs", :attribute_name => :log

      def execute
        GrokNGelf::Importers::Syslog.new(notifier, host, import_id).import(self.log)
        super
      end
    end

    GrokNGelf::Commands::MainCommand.subcommand "syslog", "process system log", GrokNGelf::Commands::SyslogCommand
  end
end
