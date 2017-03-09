require File.join(File.dirname(__FILE__), '..', 'test_helper')

describe GrokNGelf::Importers::Yum do

  let(:notifier) { mock() }
  let(:yum_importer) { GrokNGelf::Importers::Yum.new(notifier, 'localhost', 1) }

  it "parses standard log line" do
    expected_log = {
      "short_message"=>"Updated: 1:openssl-libs-1.0.1e-60.el7.x86_64",
      "original_line"=>"Feb 14 11:01:12 Updated: 1:openssl-libs-1.0.1e-60.el7.x86_64",
      "timestamp"=>1487070072,
      "level"=>1,
      "level_hr"=>"INFO",
      "importer"=>"GrokNGelf::Importers::Yum",
      "program"=>"yum",
      "action"=>"Updated",
      "package_nevra"=>"1:openssl-libs-1.0.1e-60.el7.x86_64",
      "package_name"=>"openssl-libs",
      "package_epoch"=>1,
      "package_version"=>"1.0.1e",
      "package_version_major"=>1,
      "package_version_minor"=>0,
      "package_release"=>"60.el7",
      "package_architecture"=>"x86_64"
    }
    notifier.expects(:notify).with(log_event_matcher(expected_log))

    yum_importer.import(fixture_log('yum_standard.log'))
  end
end
