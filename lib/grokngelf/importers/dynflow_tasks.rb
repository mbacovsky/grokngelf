require 'csv'
require 'json'
require 'date'
require 'sqlite3'

module GrokNGelf
  module Importers
    class DynflowTasks < GrokNGelf::Importers::Abstract

      def import(log)
        @log = log
        @execution_plans_dump = File.join(log, 'dynflow_execution_plans.csv')
        @steps_dump = File.join(log, 'dynflow_steps.csv')
        @tasks_dump = File.join(log, 'foreman_tasks_tasks.csv')
        @actions_dump = File.join(log, 'dynflow_actions.csv')

        create_database
        load_execution_plans(@execution_plans_dump)
        load_actions(@actions_dump)
        load_steps(@steps_dump)
        load_foreman_tasks_tasks(@tasks_dump)
        import_execution_plans
        import_steps
      end

      def load_execution_plans(dump)
        puts "Loading Dynflow Execution plans from [#{dump}]..."
        CSV.read(dump, headers: false).each do |row|
          @db.execute("insert into dynflow_execution_plans values ( ?, ?, ?, ?, ?, ?, ?, ?)", row)
        end
      end

      def load_actions(dump)
        puts "Loading Dynflow actions from [#{dump}]..."
        CSV.read(dump, headers: false).each do |row|
          @db.execute("insert into dynflow_actions values ( ?, ?, ?, ?, ?)", row)
        end
      end

      def load_steps(dump)
        puts "Loading Dynflow steps from [#{dump}]..."
        CSV.read(dump, headers: false).each do |row|
          @db.execute("insert into dynflow_steps values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", row)
        end
      end

      def load_foreman_tasks_tasks(dump)
        puts "Loading Foreman tasks from [#{dump}]..."
        CSV.read(dump, headers: false).each do |row|
          @db.execute("insert into foreman_tasks_tasks values ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", row)
        end
      end

      def import_execution_plans
        @db.execute("select ep.uuid, a.data, ep.state, ep.result, ep.started_at, ep.ended_at, ep.real_time, ep.execution_time,
              ftt.id, ftt.type, ftt.label, ftt.start_at, ftt.start_before
            from dynflow_execution_plans ep left join foreman_tasks_tasks ftt on ep.uuid = ftt.external_id, dynflow_actions a
            where ep.uuid = a.execution_plan_uuid and a.id = 1" ).each do |row|
          plan_data = JSON.parse(row[1])
          data = {
            'timestamp' => DateTime.strptime(row[4], '%Y-%m-%d %H:%M:%S').to_time.to_i,
            'level' => helpers.level(:INFO),
            'level_hr' => 'INFO',
            'program' => 'dynflow',
            'short_message' => "Execution plan #{row[0]} started",
            'dynflow_object' => 'execution_plan',
            'dynflow_plan_id' => row[0],
            'dynflow_class' => plan_data['class'],
            'dynflow_input' => plan_data['input'],
            'dynflow_output' => plan_data['output'],
            'dynflow_event_type' => 'start',
            'dynflow_state' => row[2],
            'dynflow_result' => row[3],
            'dynflow_started_at' => row[4],
            'dynflow_ended_at' => row[5],
            'dynflow_real_time' => row[6].to_f,
            'dynflow_real_time_hr' => helpers.humanize_elapsed_time(row[6].to_i),
            'dynflow_execution_time' => row[7].to_f,
            'foreman_task_id' => row[8],
            'foreman_task_type' => row[9],
            'foreman_task_label' => row[10],
            'foreman_task_start_at' => row[11],
            'foreman_task_start_before' => row[12],
            'log_file' => @execution_plans_dump
          }
          notify(data)
          data['timestamp'] = DateTime.strptime(row[5], '%Y-%m-%d %H:%M:%S').to_time.to_i
          data['short_message'] = "Execution plan #{row[0]} ended"
          data['dynflow_event_type'] = 'end'
          notify(data)
          update_progress
        end
        puts '|'
      end

      def import_steps
        @db.execute("select s.execution_plan_uuid, s.id, s.action_id, s.data, s.state,
              s.started_at, s.ended_at, s.real_time, s.execution_time, s.progress_done,
              s.progress_weight, a.data
            from dynflow_steps s, dynflow_actions a
            where s.execution_plan_uuid = a.execution_plan_uuid and s.action_id = a.id
            order by s.id").each do |row|
          step_data = JSON.parse(row[3])
          action_data = JSON.parse(row[11])
          data = {
            'timestamp' => DateTime.strptime(row[5], '%Y-%m-%d %H:%M:%S').to_time.to_i,
            'level' => helpers.level(:INFO),
            'level_hr' => 'INFO',
            'program' => 'dynflow',
            'short_message' => "Execution step started",
            'dynflow_object' => 'step',
            'dynflow_plan_id' => row[0],
            'dynflow_event_type' => 'start',
            'dynflow_class' => action_data['class'],
            'dynflow_step_class' => step_data['class'],
            'dynflow_step_id' => row[1],
            'dynflow_input' => action_data['input'],
            'dynflow_output' => action_data['output'],
            'dynflow_error' => step_data['error'],
            'dynflow_result' => row[4],
            'dynflow_started_at' => row[5],
            'dynflow_ended_at' => row[6],
            'dynflow_real_time' => row[7].to_f,
            'dynflow_real_time_hr' => helpers.humanize_elapsed_time(row[7].to_i),
            'dynflow_execution_time' => row[8].to_f,
            'dynflow_progress_done' => row[9],
            'dynflow_progress_weight' => row[10],
            'log_file' => @steps_dump
          }
          notify(data)
          data['timestamp'] = DateTime.strptime(row[5], '%Y-%m-%d %H:%M:%S').to_time.to_i
          data['short_message'] = "Execution step ended"
          data['dynflow_event_type'] = 'end'
          notify(data)
          update_progress
        end
        puts '|'
      end

      def create_database
        @db = SQLite3::Database.new ":memory:"

        @db.execute("
          CREATE TABLE dynflow_execution_plans (
            uuid varchar(36),
            data text,
            state text,
            result text,
            started_at text,
            ended_at text,
            real_time real,
            execution_time real
          );")

        @db.execute("
          CREATE TABLE dynflow_actions (
            execution_plan_uuid varchar(36),
            id integer,
            data text,
            caller_execution_plan_id varchar(36),
            caller_action_id integer
          );")

        @db.execute("
          CREATE TABLE dynflow_steps (
            execution_plan_uuid varchar(36),
            id integer,
            action_id integer,
            data text,
            state text,
            started_at text,
            ended_at text,
            real_time real,
            execution_time real,
            progress_done real,
            progress_weight real
          );")

        @db.execute("
          CREATE TABLE foreman_tasks_tasks (
            id text,
            type text,
            label text,
            started_at text,
            ended_at text,
            state text,
            result text,
            external_id text,
            parent_task_id text,
            start_at text,
            start_before text
          );")
      end
    end
  end
end
