class TagsController < ApplicationController
  before_action :set_tag, only: %i[books]

  def index
    tags = current_user.tags.includes(:books)

    render json: {
      data: tags.map { |tag| tag_response(tag) }
    }
  end

  def books
    books = @tag.books.includes(:tags)

    render json: {
      data: books.map { |book| book_response(book) }
    }
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Tag not found' }, status: :not_found
  end

  def tag_response(tag)
    { id: tag.id, name: tag.name, books_count: tag.books_count, created_at: tag.created_at }
  end

  def book_response(book)
    {
      id: book.id, title: book.title, author: book.author, isbn: book.isbn,
      status: book.status, rating: book.rating, notes: book.notes, url: book.url,
      tags: book.tags.map { |t| { id: t.id, name: t.name } },
      created_at: book.created_at, updated_at: book.updated_at
    }
  end
end
