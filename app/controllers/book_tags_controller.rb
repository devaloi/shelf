class BookTagsController < ApplicationController
  before_action :set_book

  def create
    tag_names = parse_tag_names
    return render_bad_request('No tags provided') if tag_names.empty?

    add_tags_to_book(tag_names)
    render json: tag_response, status: :created
  end

  def destroy
    tag = @book.tags.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound, "Couldn't find Tag on this book" unless tag

    @book.tags.delete(tag)
    render json: tag_response
  end

  private

  def set_book
    @book = current_user.books.find(params[:book_id])
  end

  def parse_tag_names
    Array(params[:tags]).map { |t| t.to_s.strip }.compact_blank
  end

  # Uses filter_map to find-or-create each tag then associate it with the book.
  # Skips (returns nil via next) tags already on the book; filter_map discards nils.
  def add_tags_to_book(tag_names)
    tag_names.filter_map do |name|
      tag = current_user.tags.find_or_create_by!(name: name)
      next if @book.tags.include?(tag)

      @book.tags << tag
      tag
    end
  end

  def tag_response
    { data: BookSerializer.new(@book.reload).as_json }
  end
end
