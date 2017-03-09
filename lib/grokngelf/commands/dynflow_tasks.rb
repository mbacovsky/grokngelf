require 'date'
require 'tmpdir'

module GrokNGelf
  module Commands
    class DynflowTasksCommand < GrokNGelf::Commands::AbstractCommand

      parameter "TASK_EXPORT", "task export (CSV) tarball or directory with csv data", :attribute_name => :log_dir

      def execute
        if !File.directory?(self.log_dir)
          out = `tar -xvf #{self.log_dir} -C /tmp`
          expanded = File.join('/tmp', out.split("/n").first.split("\n").first)
          if !File.directory?(expanded)
            puts "ERROR: untar failed (tar -xvf #{self.log_dir} -C /tmp)"
            puts out
            exit 1
          end
          puts "Task export was extracted to #{expanded}"
          self.log_dir = expanded
        end
        GrokNGelf::Importers::DynflowTasks.new(notifier, host, import_id).import(self.log_dir)
        super
      end
    end

    GrokNGelf::Commands::MainCommand.subcommand "dynflow-tasks", "process CSV export of dynflow tasks", GrokNGelf::Commands::DynflowTasksCommand
  end
end
