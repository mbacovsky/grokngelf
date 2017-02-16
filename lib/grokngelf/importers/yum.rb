module GrokNGelf
  module Importers
    class Yum < GrokNGelf::Importers::Abstract

      def import(log)
        @log = log
        puts "Importing yum log [#{log}]..."
        parser = set_parser(['yum'])
        parser.compile("%{YUMLOG}")
        year = File.ctime(log).year

        unmatched = for_matching_lines(log, parser) do |match|
          notify(
            'timestamp' => helpers.parse_syslog_date(match['timestamp'][0], year),
            'level' => helpers.level(:INFO),
            'level_hr' => 'INFO',
            'program' => 'yum',
            'original_line' => match['YUMLOG'][0],
            'short_message' => match['message'][0],
            'package_name' => match['package_name'][0],
            'action' => match['action'][0],
            'package_nevra' => match['PACKAGENEVRA'][0],
            'package_epoch' => match['epoch'][0].to_i,
            'package_version' => match['package_version'][0],
            'package_version_major' => match['version_major'][0].to_i,
            'package_version_minor' => match['version_minor'][0].to_i,
            'package_release' => match['release'][0],
            'package_architecture' => match['architecture'][0]
          )
        end
        dump_unmatched(unmatched)
      end
    end
  end
end
