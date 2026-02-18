class BookTagsController < ApplicationController
  before_action :set_book

  def create
    tag_names = parse_tag_names
    return render json: { error: 'No tags provided' }, status: :bad_request if tag_names.empty?

    added_tags = add_tags_to_book(tag_names)
    render json: tag_response("Added #{added_tags.size} tag(s)"), status: :created
  end

  def destroy
    tag = @book.tags.find_by(id: params[:id])
    return render json: { error: 'Tag not found on this book' }, status: :not_found unless tag

    @book.tags.delete(tag)
    render json: tag_response('Tag removed from book')
  end

  private

  def set_book
    @book = current_user.books.find(params[:book_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Book not found' }, status: :not_found
  end

  def parse_tag_names
    Array(params[:tags]).map { |t| t.to_s.strip }.compact_blank
  end

  def add_tags_to_book(tag_names)
    tag_names.filter_map do |name|
      tag = current_user.tags.find_or_create_by!(name: name)
      next if @book.tags.include?(tag)

      @book.tags << tag
      tag
    end
  end

  def tag_response(message)
    {
      data: { book_id: @book.id, tags: @book.tags.reload.map { |t| { id: t.id, name: t.name } } },
      message: message
    }
  end
end
