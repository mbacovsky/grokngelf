require 'date'
require 'grokngelf/importers/yum'

module GrokNGelf
  module Commands
    class YumCommand < GrokNGelf::Commands::AbstractCommand

      parameter "LOG_FILE", "file containing the logs", :attribute_name => :log

      def execute
        GrokNGelf::Importers::Yum.new(notifier, host, import_id).import(self.log)
        super
      end
    end

    GrokNGelf::Commands::MainCommand.subcommand "yum", "process yum log", GrokNGelf::Commands::YumCommand
  end
end
