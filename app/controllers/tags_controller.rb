class TagsController < ApplicationController
  before_action :set_tag, only: %i[books]

  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

  def index
    tags = current_user.tags.includes(:books)

    render json: {
      data: tags.map { |tag| TagSerializer.new(tag).as_json }
    }
  end

  def books
    books = @tag.books.includes(:tags)
    books, pagination = paginate(books)

    render json: {
      data: books.map { |book| BookSerializer.new(book).as_json },
      meta: pagination
    }
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  end

  def paginate(books)
    page = [params[:page].to_i, 1].max
    per_page = parse_per_page
    total = books.count

    [books.offset((page - 1) * per_page).limit(per_page),
     { page: page, per_page: per_page, total: total, total_pages: (total.to_f / per_page).ceil }]
  end

  def parse_per_page
    return DEFAULT_PER_PAGE if params[:per_page].blank?

    params[:per_page].to_i.clamp(1, MAX_PER_PAGE)
  end
end
