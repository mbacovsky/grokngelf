require 'date'

module GrokNGelf
  module Importers
    class Helpers
      def parse_syslog_date(date_str, year=DateTime.now.year)
        # parses dates in syslog format 'Jan 27 09:20:39'
        date = DateTime.strptime(date_str+" #{year}", '%b %d %H:%M:%S %Y')
        date = DateTime.strptime(date_str+" #{year-1}", '%b %d %H:%M:%S %Y') if date > DateTime.now
        date.to_time.to_i
      end

      def level(level)
        GrokNGelf::LogEvent::LEVEL[level.to_sym]
      end

      def humanize_elapsed_time(secs)
        [[60, :s], [60, :m], [24, :h], [1000, :d]].map{ |count, name|
          if secs > 0
            secs, n = secs.divmod(count)
            "#{n.to_i} #{name}"
          end
        }.compact.reverse.join(' ')
      end
    end
  end
end
