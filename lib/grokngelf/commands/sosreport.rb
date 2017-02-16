require 'date'
require 'tmpdir'

module GrokNGelf
  module Commands
    class SOSReportCommand < GrokNGelf::Commands::AbstractCommand

      parameter "SOSREPORT", "sosreport tarball or directory with extracted logs", :attribute_name => :log_dir

      def execute
        if !File.directory?(self.log_dir)
          out = `tar -xvf #{self.log_dir} -C /tmp`
          expanded = File.join('/tmp', out.split("/n").first.split("\n").first)
          if !File.directory?(expanded)
            puts "ERROR: untar failed (tar -xvf #{self.log_dir} -C /tmp)"
            puts out
            exit 1
          end
          puts "sosreport was extracted to #{expanded}"
          self.log_dir = expanded
        end
        GrokNGelf::Importers::SOSReport.new(notifier, host, import_id).import(self.log_dir)
        super
      end
    end

    GrokNGelf::Commands::MainCommand.subcommand "sosreport", "process sos report", GrokNGelf::Commands::SOSReportCommand
  end
end
