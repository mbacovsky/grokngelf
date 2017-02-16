module GrokNGelf
  module Commands
    class AbstractCommand < Clamp::Command

      option ['--target', '-t'], 'TARGET', 'machine where we can send the processed logs', :required => true
      option ['--port', '-p'], 'PORT', 'port where we can send the processed logs', :default => '12201'
      option ['--protocol'], 'PROTOCOL', 'protocol to use to send the data', :default => 'TCP'
      # option ['--cut'], :flag, 'remove the processed lines from the log', :default => false
      option ['--host'], 'HOST', 'hostname of the machine the logs originates from (a.k.a facilty)', :default => 'default'
      option ['--import-id'], 'IMPORT_ID', 'unique identification of the import', :default => 1

      def execute
        puts 'Done'
        0
      end

      private

      def get_protocol
        case protocol
        when 'UDP'
          GELF::Protocol::UDP
        when 'TCP'
          GELF::Protocol::TCP
        else
          puts "Unknown protocol #{protocol}. Use either 'UDP' or 'TCP'"
          exit 1
        end
      end

      def notifier
        @notifier ||= GELF::Notifier.new(target, port, 'WAN', :protocol => get_protocol)
      end
    end
  end
end
