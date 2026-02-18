module Paginatable
  extend ActiveSupport::Concern

  private

  def paginate(scope)
    page = [params[:page].to_i, 1].max
    per = parse_per_page
    total = scope.count

    [scope.offset((page - 1) * per).limit(per),
     { page: page, per_page: per, total: total, total_pages: (total.to_f / per).ceil }]
  end

  def parse_per_page
    return DEFAULT_PER_PAGE if params[:per_page].blank?

    params[:per_page].to_i.clamp(1, MAX_PER_PAGE)
  end
end
