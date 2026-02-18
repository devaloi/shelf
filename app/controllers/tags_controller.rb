class TagsController < ApplicationController
  before_action :set_tag, only: %i[books]

  def index
    tags = current_user.tags.includes(:books)

    render json: {
      data: tags.map { |tag| TagSerializer.new(tag).as_json }
    }
  end

  def books
    books = @tag.books.includes(:tags)

    render json: {
      data: books.map { |book| BookSerializer.new(book).as_json }
    }
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Tag not found' }, status: :not_found
  end
end
