module GrokNGelf
  class LogEvent

    LEVEL = {
      :DEBUG   => 0,
      :INFO    => 1,
      :WARN    => 2,
      :ERROR   => 3,
      :FATAL   => 4,
      :UNKNOWN => 5,
    }

    def initialize(data={})
      @event = {
          'version' => '1.1',               # GELF version, *internal*
          'import_id' => '',                # id of the import as set on CLI
          'source' => '',                   # hostname of importer machine, *internal*
          'short_message' => '',            # log entry without timestamps, pids, etc.
          'original_line' => '',            # full original log entry
          'timestamp' => Time.now.getutc,   # log event timestamp
          'level' => LEVEL[:DEBUG],         # log level number
          'level_hr' => 'DEBUG',            # log level in human readable format
          'facility' => '',                 # source (hostname) of the log entry, set on CLI
          'file' => 'N/A',                  # file the notify was called from *internal*
          'line' => 'N/A',                  # line the notify was called from *internal*
          'log_file' => '',                 # file that was parsed to produce this entry
        }.merge(data)
    end

    def to_hash
      @event
    end
  end
end
