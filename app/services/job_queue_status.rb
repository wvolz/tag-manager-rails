class JobQueueStatus
  HEARTBEAT_STALE_AFTER = 2.minutes

  def self.snapshot(...)
    new(...).snapshot
  end

  def initialize(
    now: Time.current,
    adapter_name: ActiveJob::Base.queue_adapter.class.name,
    job_class: SolidQueue::Job,
    ready_execution_class: SolidQueue::ReadyExecution,
    scheduled_execution_class: SolidQueue::ScheduledExecution,
    claimed_execution_class: SolidQueue::ClaimedExecution,
    failed_execution_class: SolidQueue::FailedExecution,
    blocked_execution_class: SolidQueue::BlockedExecution,
    process_class: SolidQueue::Process
  )
    @now = now
    @adapter_name = adapter_name.to_s
    @job_class = job_class
    @ready_execution_class = ready_execution_class
    @scheduled_execution_class = scheduled_execution_class
    @claimed_execution_class = claimed_execution_class
    @failed_execution_class = failed_execution_class
    @blocked_execution_class = blocked_execution_class
    @process_class = process_class
  end

  def snapshot
    return unavailable_status(adapter_unavailable_message) unless solid_queue_adapter?
    return unavailable_status("Solid Queue tables are not present in this environment.") unless queue_tables_present?

    {
      available: true,
      adapter: human_adapter_name,
      totals: queue_totals,
      queues: queued_jobs_by_queue,
      workers: worker_counts,
      recent_failures: recent_failures
    }
  rescue ActiveRecord::ActiveRecordError => error
    unavailable_status("Queue status could not be loaded: #{error.message}")
  end

  private

  attr_reader :adapter_name,
              :blocked_execution_class,
              :claimed_execution_class,
              :failed_execution_class,
              :job_class,
              :now,
              :process_class,
              :ready_execution_class,
              :scheduled_execution_class

  def solid_queue_adapter?
    adapter_name.include?("SolidQueue")
  end

  def human_adapter_name
    adapter_name.sub(/Adapter\z/, "").demodulize.underscore.humanize.titleize
  end

  def adapter_unavailable_message
    "Active Job adapter is #{human_adapter_name}, so no Solid Queue backlog is available here."
  end

  def unavailable_status(message)
    {
      available: false,
      adapter: human_adapter_name,
      message: message,
      totals: {},
      queues: {},
      workers: {},
      recent_failures: []
    }
  end

  def queue_tables_present?
    required_models.all?(&:table_exists?)
  end

  def required_models
    [
      job_class,
      ready_execution_class,
      scheduled_execution_class,
      claimed_execution_class,
      failed_execution_class,
      blocked_execution_class,
      process_class
    ]
  end

  def queue_totals
    {
      ready: ready_execution_class.count,
      scheduled: scheduled_execution_class.count,
      running: claimed_execution_class.count,
      failed: failed_execution_class.count,
      blocked: blocked_execution_class.count
    }
  end

  def queued_jobs_by_queue
    job_class.where(finished_at: nil).group(:queue_name).count.sort_by { |queue_name, count| [ -count, queue_name ] }.to_h
  end

  def worker_counts
    total = process_class.count
    live = process_class.where("last_heartbeat_at >= ?", now - HEARTBEAT_STALE_AFTER).count

    {
      live: live,
      stale: total - live,
      total: total
    }
  end

  def recent_failures
    failed_execution_class.includes(:job).order(created_at: :desc).limit(5).map do |failure|
      {
        class_name: failure.job&.class_name || "Unknown job",
        queue_name: failure.job&.queue_name || "unknown",
        failed_at: failure.created_at,
        error: summarized_error(failure.error)
      }
    end
  end

  def summarized_error(error)
    error.to_s.lines.first.to_s.strip
  end
end
