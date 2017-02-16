Grok'n'Gelf
===========

Tool for parsing logs collected by `foreman-debug` and `sosreport` tools
and import them to a centralized log manager.

How do I use it
---------------
Log server is not part of this tool. You can use service of your choice.
The only requirement is it has to accept log data in `GELF` format.
The tool was tested with [Graylog server](https://www.graylog.org/)

Install the tool:
```
  git clone https://github.com/mbacovsky/grokngelf
  cd grokngelf
  bundle install
  bundle exec bin/grokngelf -h
```

Lets assume you have your Graylog server running at `graylog.example.com`
and accepting `GELF` input on port `12201` via `TCP`. Also assume you have your
sosreport extracted in `/tmp/sosreport-sample`. To import the logs run:

```
  $ grokngelf sosreport -t graylog.example.com --host testhost.example.com --import-id 1 /tmp/sosreport-sample

  Importing sosreport from [/tmp/sosreport-sample]...
  Importing yum log [/tmp/sosreport-sample/var/log/yum.log].....................................................................|
  Importing syslog [/tmp/sosreport-sample/var/log/messages]..........................................|
  Done
```

If you sosreport is a tarball the tool can extract it for you:

```
  $ grokngelf sosreport -t graylog.example.com --host testhost.example.com --import-id 1 /tmp/sosreport-sample.tar.xz
```

For more help see:

```
  $ grokngelf -h
  Usage:
      grokngelf [OPTIONS] SUBCOMMAND [ARG] ...

  Parameters:
      SUBCOMMAND                    subcommand
      [ARG] ...                     subcommand arguments

  Subcommands:
      yum                           process yum log
      syslog                        process system log
      sosreport                     process sos report

  Options:
      -h, --help                    print help


  $ grokngelf sosreport -h
  Usage:
      grokngelf sosreport [OPTIONS] SOSREPORT

  Parameters:
      SOSREPORT                     sosreport tarball or directory with extracted logs

  Options:
      -h, --help                    print help
      --target, -t TARGET           machine where we can send the processed logs
      --port, -p PORT               port where we can send the processed logs (default: "12201")
      --protocol PROTOCOL           protocol to use to send the data (default: "TCP")
      --host HOST                   hostname of the machine the logs originates from (a.k.a facilty) (default: "default")
      --import-id IMPORT_ID         unique identification of the import (default: 1)
```  

How does it work
----------------
For sosreport all applicable importers are called for the relevant logs from collection.
Importer reads the log line by line and tries to match the line
to [GROK patterns](https://github.com/jordansissel/ruby-grok)
from its library. From the matched line structured event is created and send in
[GELF](http://docs.graylog.org/en/2.2/pages/gelf.html) format to the logging service.

For more complex logs such as `syslog` we need to parse the content in multiple runs
and every pass pick data just for specific pattern. Lines that were not matched are imported with `program: 'unmatched'` and can be filtered and revieved later.

Each event has mandatory attributes regardless of importer it originates from:

```ruby
  {
    'version' => '1.1',               # GELF version, *internal*
    'import_id' => '',                # id of the import as set on CLI
    'source' => '',                   # hostname of importer machine, *internal*
    'short_message' => '',            # log entry without timestamps, pids, etc.
    'original_line' => '',            # full original log entry
    'timestamp' => 1485359137,        # log event timestamp
    'level' => 1,                     # log level number
    'level_hr' => 'DEBUG',            # log level in human readable format
    'facility' => '',                 # source (hostname) of the log entry, set on CLI
    'file' => 'N/A',                  # file the notify was called from *internal*
    'line' => 'N/A',                  # line the notify was called from *internal*
    'log_file' => '',                 # file that was parsed to produce this entry
  }
```


What logs are supported
-----------------------

### `var/log/yum.log`
 - *Importer:* `Yum`
 - *Status*: *Complete*
 - *Example*:
```ruby
{
            "original_line" => "Jan 25 15:45:37 Installed: rh-ruby22-ruby-2.2.2-16.el7.x86_64",
                "timestamp" => 1485359137,
                    "level" => 1,
                 "level_hr" => "INFO",
                  "program" => "yum",
            "short_message" => "Installed: rh-ruby22-ruby-2.2.2-16.el7.x86_64",
             "package_name" => "rh-ruby22-ruby",
                   "action" => "Installed",
            "package_nevra" => "rh-ruby22-ruby-2.2.2-16.el7.x86_64",
            "package_epoch" => 0,
          "package_version" => "2.2.2",
    "package_version_major" => 2,
    "package_version_minor" => 2,
          "package_release" => "16.el7",
     "package_architecture" => "x86_64"
}
```

### `var/log/messages`
 - *Importer:* `Syslog`
 - *Status*: *WIP*
 - *Pulp messages*
 - *Generic syslog messages*


How can I improve it
--------------------
Any contribution is highly appreciated. I welcome any kind of help

 - report [issues](https://github.com/mbacovsky/grokngelf/issues)
 - send [feature your requests and ideas](https://github.com/mbacovsky/grokngelf/issues)
 - improve documentation
 - send [PRs](https://github.com/mbacovsky/grokngelf/pulls) with fixes
 - develop new importers

License
-------
This project is licensed under the GPLv3+.
