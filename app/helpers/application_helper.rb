module ApplicationHelper
  include Pagy::Frontend

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to({:sort => column, :direction => direction}, {:class=> css_class}) do
      "#{title} #{content_tag(:i, '', :class=>"fa fa-chevron-#{direction=='asc'?'up':'down'}", :style=>"font-size: 6px;") if css_class.present?}".html_safe
    end
  end

end
