module ApplicationHelper
  include Pagy::Frontend

  # below from: https://blog.albertorocha.me/posts/overwriting-pagy-navigation-helper
  def pagy_nav(pagy)
      html = %(<div class="join" aria-label="Pages">)

      if pagy.prev
        html << %(<a href="#{pagy_url_for(pagy, pagy.prev)}" class="join-item btn" aria-label="Previous">«</a>)
      else
        html << %(<button class="join-item btn" aria-disabled="true" aria-label="Previous">«</button>)
      end

      pagy.series.each do |item|
        if item.is_a? Integer
          html << %(<a href="#{pagy_url_for(pagy, item)}" class="join-item btn">#{item}</a>)
        elsif item.is_a? String
          html << %(<button class="join-item btn btn-active" aria-disabled="true" aria-current="page">#{item}</button>)
        elsif item == :gap
          html << %(<button class="join-item btn btn-disabled" aria-disabled="true">...</button>)
        end
      end

      if pagy.next
        html << %(<a href="#{pagy_url_for(pagy, pagy.next)}" class="join-item btn" aria-label="Next">»</a>)
      else
        html << %(<button class="join-item btn" aria-disabled="true" aria-label="Next">»</button>)
      end

      html << %(</div>)

      html.html_safe
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    active = column == sort_column
    current_direction = active ? sort_direction : nil
    next_direction = active && sort_direction == "asc" ? "desc" : "asc"

    link_classes = [
      "inline-flex items-center gap-1 rounded px-2 py-1 transition-colors",
      (active ? "bg-base-200 text-base-content font-semibold ring-1 ring-base-300" : "text-base-content/70 hover:text-base-content hover:bg-base-200/70")
    ].join(" ")

    sort_state = if current_direction == "asc"
      "currently sorted ascending"
    elsif current_direction == "desc"
      "currently sorted descending"
    else
      "not currently sorted"
    end

    aria_label = "Sort by #{title}, #{sort_state}"

    link_to(request.query_parameters.merge(sort: column, direction: next_direction), class: link_classes, aria: { label: aria_label }) do
      safe_join([
        content_tag(:span, title),
        sort_indicator_icon(current_direction, active)
      ])
    end
  end

  def sort_indicator_icon(direction, active)
    icon_classes = [
      "h-4 w-4",
      (active ? "text-primary" : "text-base-content/60")
    ].join(" ")

    content_tag(:svg, class: icon_classes, viewBox: "0 0 20 20", fill: "currentColor", aria: { hidden: true }) do
      paths = if direction == "asc"
        [
          tag.path(d: "M10 4l4.5 5h-9L10 4z"),
          tag.rect(x: "9", y: "9", width: "2", height: "7", rx: "1")
        ]
      elsif direction == "desc"
        [
          tag.rect(x: "9", y: "4", width: "2", height: "7", rx: "1"),
          tag.path(d: "M10 16l-4.5-5h9L10 16z")
        ]
      else
        [
          tag.path(d: "M10 3.5l4 4.5h-8L10 3.5z"),
          tag.path(d: "M10 16.5l-4-4.5h8L10 16.5z")
        ]
      end

      safe_join(paths)
    end
  end
end
