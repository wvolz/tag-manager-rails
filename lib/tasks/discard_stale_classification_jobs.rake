namespace :queue do
  desc "Discard queued ClassifyTagscanImageJob jobs for tagscans without attached images"
  task discard_stale_classification_jobs: :environment do
    dry_run = ENV["DRY_RUN"] == "1"

    unless defined?(SolidQueue::Job) && SolidQueue::Job.table_exists?
      puts "Solid Queue tables are not available in this environment."
      exit 1
    end

    pending_jobs = SolidQueue::Job.where(class_name: "ClassifyTagscanImageJob", finished_at: nil)

    ready_jobs = pending_jobs.joins(:ready_execution).to_a
    scheduled_jobs = pending_jobs.joins(:scheduled_execution).to_a

    jobs_by_execution = {
      ready: ready_jobs,
      scheduled: scheduled_jobs
    }

    all_jobs = ready_jobs + scheduled_jobs
    all_parsed_pairs = all_jobs.filter_map do |job|
      begin
        args = JSON.parse(job.arguments)
        [ job, args.dig("arguments", 0) ]
      rescue JSON::ParserError
        [ job, nil ]
      end
    end

    all_tagscan_ids = all_parsed_pairs.map(&:last).compact.uniq
    existing_ids_with_image = Tagscan.with_attached_image.where(id: all_tagscan_ids).pluck(:id).to_set

    total_discarded = 0

    jobs_by_execution.each do |execution_type, jobs|
      next if jobs.empty?

      parsed_pairs = jobs.filter_map do |job|
        begin
          args = JSON.parse(job.arguments)
          [ job, args.dig("arguments", 0) ]
        rescue JSON::ParserError
          [ job, nil ]
        end
      end

      jobs_to_discard = parsed_pairs.filter_map do |job, tagscan_id|
        next job if tagscan_id.nil?
        next job unless existing_ids_with_image.include?(tagscan_id)

        nil
      end

      next if jobs_to_discard.empty?

      unless dry_run
        case execution_type
        when :ready
          SolidQueue::ReadyExecution.discard_all_from_jobs(jobs_to_discard)
        when :scheduled
          SolidQueue::ScheduledExecution.discard_all_from_jobs(jobs_to_discard)
        end
      end

      total_discarded += jobs_to_discard.size
    end

    if dry_run
      puts "DRY_RUN=1: would discard #{total_discarded} stale classification job(s)."
    else
      puts "Discarded #{total_discarded} stale classification job(s)."
    end
  end
end
