require "test_helper"

class JobQueueStatusTest < ActiveSupport::TestCase
  CountModel = Struct.new(:count_value, keyword_init: true) do
    def table_exists?
      true
    end

    def count
      count_value
    end
  end

  GroupedCounts = Struct.new(:counts) do
    def group(_column)
      self
    end

    def count
      counts
    end
  end

  CountRelation = Struct.new(:value) do
    def count
      value
    end
  end

  QueueJobModel = Struct.new(:counts, keyword_init: true) do
    def table_exists?
      true
    end

    def where(*_args)
      GroupedCounts.new(counts)
    end
  end

  ProcessModel = Struct.new(:total, :live, keyword_init: true) do
    def table_exists?
      true
    end

    def count
      total
    end

    def where(*_args)
      CountRelation.new(live)
    end
  end

  OrderedFailures = Struct.new(:records) do
    def order(*_args)
      self
    end

    def limit(_limit)
      records
    end
  end

  FailureJob = Struct.new(:class_name, :queue_name, keyword_init: true)
  FailureRecord = Struct.new(:job, :created_at, :error, keyword_init: true)
  FailureModel = Struct.new(:count_value, :records, keyword_init: true) do
    def table_exists?
      true
    end

    def count
      count_value
    end

    def includes(*_args)
      OrderedFailures.new(records)
    end
  end

  test "snapshot reports unavailable when adapter is not solid queue" do
    snapshot = JobQueueStatus.new(adapter_name: "ActiveJob::QueueAdapters::TestAdapter").snapshot

    assert_not snapshot[:available]
    assert_equal "Test", snapshot[:adapter]
    assert_match(/Active Job adapter is Test/, snapshot[:message])
  end

  test "snapshot summarizes solid queue counts when available" do
    service = JobQueueStatus.new(
      now: Time.utc(2026, 6, 14, 12, 0, 0),
      adapter_name: "ActiveJob::QueueAdapters::SolidQueueAdapter",
      job_class: QueueJobModel.new(counts: { "default" => 4, "mailers" => 1 }),
      ready_execution_class: CountModel.new(count_value: 4),
      scheduled_execution_class: CountModel.new(count_value: 2),
      claimed_execution_class: CountModel.new(count_value: 1),
      blocked_execution_class: CountModel.new(count_value: 3),
      failed_execution_class: FailureModel.new(
        count_value: 1,
        records: [
        FailureRecord.new(
          job: FailureJob.new(class_name: "PurgeTagscanImagesJob", queue_name: "default"),
          created_at: Time.utc(2026, 6, 14, 11, 55, 0),
          error: "RuntimeError: boom\n/trace/line"
        )
        ]
      ),
      process_class: ProcessModel.new(total: 3, live: 2)
    )

    snapshot = service.snapshot

    assert snapshot[:available]
    assert_equal "Solid Queue", snapshot[:adapter]
    assert_equal({ ready: 4, scheduled: 2, running: 1, failed: 1, blocked: 3 }, snapshot[:totals])
    assert_equal({ "default" => 4, "mailers" => 1 }, snapshot[:queues])
    assert_equal({ live: 2, stale: 1, total: 3 }, snapshot[:workers])
    assert_equal 1, snapshot[:recent_failures].size
    assert_equal "PurgeTagscanImagesJob", snapshot[:recent_failures].first[:class_name]
    assert_equal "RuntimeError: boom", snapshot[:recent_failures].first[:error]
  end
end
