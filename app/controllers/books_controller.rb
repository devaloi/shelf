class BooksController < ApplicationController
  include Paginatable

  before_action :set_book, only: %i[show update destroy]

  def index
    books = current_user.books.includes(:tags)
    books = apply_filters(books)
    books = apply_sorting(books)
    books, pagination = paginate(books)

    render json: {
      data: books.map { |book| BookSerializer.new(book).as_json },
      meta: pagination
    }
  end

  def show
    render json: { data: BookSerializer.new(@book).as_json }
  end

  def create
    book = current_user.books.create!(book_params)
    render json: { data: BookSerializer.new(book).as_json }, status: :created
  end

  def update
    @book.update!(book_params)
    render json: { data: BookSerializer.new(@book).as_json }
  end

  def destroy
    @book.destroy!
    head :no_content
  end

  def search
    query = params[:q].to_s.strip
    return render_bad_request('Search query required') if query.blank?

    books = BookSearchService.new(current_user.books.includes(:tags)).call(query)
    books, pagination = paginate(books)

    render json: {
      data: books.map { |book| BookSerializer.new(book).as_json },
      meta: pagination
    }
  end

  private

  def set_book
    @book = current_user.books.find(params[:id])
  end

  def book_params
    params.permit(:title, :author, :isbn, :status, :rating, :notes, :url)
  end

  def apply_filters(books)
    books = books.by_status(params[:status]) if params[:status].present?
    books = books.by_tag(params[:tag]) if params[:tag].present?
    books
  end

  # Validates sort params against an allowlist using presence_in(),
  # which returns nil if the value isn't in the array — falling back to defaults.
  def apply_sorting(books)
    sort_field = params[:sort].presence_in(%w[title author created_at rating]) || 'created_at'
    sort_order = params[:order].presence_in(%w[asc desc]) || 'desc'
    books.order(sort_field => sort_order)
  end
end
