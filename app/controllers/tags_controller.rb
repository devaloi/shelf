class TagsController < ApplicationController
  include Paginatable

  before_action :set_tag, only: %i[books]

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
end
