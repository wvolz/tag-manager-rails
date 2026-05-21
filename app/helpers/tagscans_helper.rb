module TagscansHelper
	def tagscan_classification_status_label(tagscan)
		case tagscan.image_classification_status
		when "queued"
			"Queued"
		when "processing"
			"Processing"
		when "classified"
			"Classified"
		when "failed"
			"Failed"
		else
			"Unclassified"
		end
	end

	def tagscan_classification_status_badge_class(tagscan)
		case tagscan.image_classification_status
		when "classified"
			"badge-success"
		when "failed"
			"badge-error"
		when "processing", "queued"
			"badge-warning"
		else
			"badge-ghost"
		end
	end

	def tagscan_detection_badge_class(type)
		case type.to_sym
		when :person
			"badge-info"
		when :vehicle
			"badge-primary"
		when :animal
			"badge-accent"
		else
			"badge-outline"
		end
	end

	def format_detection_confidence(confidence)
		number_to_percentage(confidence.to_f * 100, precision: 1)
	end
end
