module ApplicationHelper
  include Pagy::Frontend

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
