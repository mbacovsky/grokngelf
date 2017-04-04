require File.join(File.dirname(__FILE__), '..', 'test_helper')

describe GrokNGelf::Importers::DynflowTasks do

  let(:notifier) { mock() }
  let(:dt_importer) { GrokNGelf::Importers::DynflowTasks.new(notifier, 'localhost', 1) }
  let(:expected_ep_log) {
    {
      "timestamp"=>1485035640,
      "level"=>1,
      "level_hr"=>"INFO",
      "importer"=>"GrokNGelf::Importers::DynflowTasks",
      'program' => 'dynflow',
      'short_message' => "Execution plan 3926bad1-7b7d-4a49-9e86-e31e4f431483 started",
      'dynflow_object' => 'execution_plan',
      'dynflow_plan_id' => '3926bad1-7b7d-4a49-9e86-e31e4f431483',
      'dynflow_class' => 'Actions::RemoteExecution::RunHostsJob',
      'dynflow_input' => {"job_invocation"=>{"id"=>2, "name"=>"Commands", "description"=>"Run echo hello"}},
      'dynflow_output' => {"total_count"=>1, "failed_count"=>0, "success_count"=>1, "pending_count"=>0},
      'dynflow_event_type' => 'start',
      'dynflow_state' => 'stopped',
      'dynflow_result' => 'success',
      'dynflow_started_at' => '2017-01-21 21:54:00',
      'dynflow_ended_at' => '2017-01-21 21:54:03',
      'dynflow_real_time' => 3.601317757,
      'dynflow_real_time_hr' => '3 s',
      'dynflow_execution_time' => 0.440313698,
      'foreman_task_start_at' => '2017-01-21 21:54:00.053138',
      'foreman_task_start_before' => '2017-01-21 21:54:00.053138',
      'foreman_task_id' => 'd8a0ec75-b056-4102-be4d-f211dc8734be',
      'foreman_task_type' => 'ForemanTasks::Task::DynflowTask',
      'foreman_task_label' => 'Actions::RemoteExecution::RunHostsJob',
      'log_file' => fixture_log('dynflow_tasks_success/dynflow_execution_plans.csv')
    }
  }
  let(:expected_step_log) {
    {
      'timestamp' => 1485035641,
      'level' => 1,
      'level_hr' => 'INFO',
      'program' => 'dynflow',
      'short_message' => "Execution step started",
      'dynflow_object' => 'step',
      'dynflow_plan_id' => '3926bad1-7b7d-4a49-9e86-e31e4f431483',
      'dynflow_event_type' => 'start',
      'dynflow_class' => 'Actions::RemoteExecution::RunHostsJob',
      'dynflow_step_class' => 'Dynflow::ExecutionPlan::Steps::RunStep',
      'dynflow_input' => {"job_invocation"=>{"id"=>2, "name"=>"Commands", "description"=>"Run echo hello"}},
      'dynflow_output' => {"total_count"=>1, "failed_count"=>0, "success_count"=>1, "pending_count"=>0},
      'dynflow_error' => nil,
      'dynflow_step_id' => 2,
      'dynflow_result' => 'success',
      'dynflow_started_at' => '2017-01-21 21:54:01',
      'dynflow_ended_at' => '2017-01-21 21:54:03',
      'dynflow_real_time' => 2.376708706,
      'dynflow_real_time_hr' => '2 s',
      'dynflow_execution_time' => 0.394046164,
      'dynflow_progress_done' => 1.0,
      'dynflow_progress_weight' => 1.0,
      'log_file' => fixture_log('dynflow_tasks_success/dynflow_steps.csv')
    }
  }

  it "imports successfull execution plan start" do
    notifier.expects(:notify).at_least(1)
    notifier.expects(:notify).with(log_event_matcher(expected_ep_log, 1))
    dt_importer.import(fixture_log('dynflow_tasks_success'))
  end

  it "imports successfull execution plan end" do
    expected_log = expected_ep_log.merge({
      "timestamp"=>1485035643,
      'short_message' => "Execution plan 3926bad1-7b7d-4a49-9e86-e31e4f431483 ended",
      'dynflow_event_type' => 'end',
    })
    notifier.expects(:notify).at_least(1)
    notifier.expects(:notify).with(log_event_matcher(expected_log, 2)) # 2nd notify call
    dt_importer.import(fixture_log('dynflow_tasks_success'))
  end

  it "imports successfull step start" do
    notifier.expects(:notify).at_least(1)
    notifier.expects(:notify).with(log_event_matcher(expected_step_log, 5)) # 5th notify call, 2nd step
    dt_importer.import(fixture_log('dynflow_tasks_success'))
  end

  it "imports successfull step end" do
    expected_log = expected_step_log.merge({
      "timestamp"=>1485035641,
      'short_message' => "Execution step ended",
      'dynflow_event_type' => 'end',
    })
    notifier.expects(:notify).at_least(1)
    notifier.expects(:notify).with(log_event_matcher(expected_log, 6)) # 6th notify call, 2nd step
    dt_importer.import(fixture_log('dynflow_tasks_success'))
  end
end
