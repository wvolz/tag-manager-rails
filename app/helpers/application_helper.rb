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

  # rubocop:disable Rails/OutputSafety
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to({ sort: column, direction: }, { class: css_class }) do
      "#{title} #{if css_class.present?
                    content_tag(
                      :i,
                      "",
                      class: "fas fa-chevron-#{direction == "asc" ? "up" : "down"}",
                      style: "font-size: 6px;"
                    )
                  end}".html_safe
    end
  end
  # rubocop:enable Rails/OutputSafety
end
