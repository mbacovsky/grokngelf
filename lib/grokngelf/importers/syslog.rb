module GrokNGelf
  module Importers
    class Syslog < GrokNGelf::Importers::Abstract

      def import(log)
        @log = log
        puts "Importing syslog [#{@log}]..."
        year = File.mtime(@log).year
        parser = set_parser(['pulp'])
        parser.compile("%{PULPLOG}")

        unmatched = for_matching_lines(@log, parser) do |match|
          notify(
            'timestamp' => helpers.parse_syslog_date(match['timestamp'][0], year),
            'level' => helpers.level(match['level'][0]),
            'level_hr' => match['level'][0],
            'program' => 'pulp',
            'source' => match['logsource'][0],
            'original_line' => match['PULPLOG'][0],
            'short_message' => match['message'][0],
            'pulp_class' => match['pulp_class'][0],
          )
        end

        parser.compile("%{SYSLOG}")
        unmatched = for_matching_lines(unmatched, parser) do |match|
          notify(
            'timestamp' => helpers.parse_syslog_date(match['timestamp'][0], year),
            'program' => match['message'][0],
            'pid' => match['pid'][0],
            'source' => match['logsource'][0],
            'original_line' => match['SYSLOG'][0],
            'short_message' => match['message'][0],
          )
        end
        dump_unmatched(unmatched)
      end
    end
  end
end
