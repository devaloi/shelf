class BooksController < ApplicationController
  before_action :set_book, only: %i[show update destroy]

  DEFAULT_PER_PAGE = 20
  MAX_PER_PAGE = 100

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
    book = current_user.books.new(book_params)

    if book.save
      render json: { data: BookSerializer.new(book).as_json }, status: :created
    else
      render json: { error: 'Failed to create book', details: book.errors.full_messages },
             status: :unprocessable_content
    end
  end

  def update
    if @book.update(book_params)
      render json: { data: BookSerializer.new(@book).as_json }
    else
      render json: { error: 'Failed to update book', details: @book.errors.full_messages },
             status: :unprocessable_content
    end
  end

  def destroy
    @book.destroy
    head :no_content
  end

  def search
    query = params[:q].to_s.strip
    return render json: { error: 'Search query required' }, status: :bad_request if query.blank?

    books = current_user.books.includes(:tags).search(query)
    books, pagination = paginate(books)

    render json: {
      data: books.map { |book| BookSerializer.new(book).as_json },
      meta: pagination
    }
  end

  private

  def set_book
    @book = current_user.books.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Book not found' }, status: :not_found
  end

  def book_params
    params.permit(:title, :author, :isbn, :status, :rating, :notes, :url)
  end

  def apply_filters(books)
    books = books.by_status(params[:status]) if params[:status].present?
    books = books.by_tag(params[:tag]) if params[:tag].present?
    books
  end

  def apply_sorting(books)
    sort_field = params[:sort].presence_in(%w[title author created_at rating]) || 'created_at'
    sort_order = params[:order].presence_in(%w[asc desc]) || 'desc'
    books.order(sort_field => sort_order)
  end

  def paginate(books)
    page = [params[:page].to_i, 1].max
    per_page = parse_per_page
    total = books.count

    [books.offset((page - 1) * per_page).limit(per_page), build_pagination(page, per_page, total)]
  end

  def parse_per_page
    return DEFAULT_PER_PAGE if params[:per_page].blank?

    params[:per_page].to_i.clamp(1, MAX_PER_PAGE)
  end

  def build_pagination(page, per_page, total)
    { page: page, per_page: per_page, total: total, total_pages: (total.to_f / per_page).ceil }
  end
end
