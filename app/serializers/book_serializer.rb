# Plain Ruby serializer — no gem dependency (ActiveModelSerializers, jbuilder).
# Gives explicit control over JSON shape and avoids hidden serialization magic.
class BookSerializer
  def initialize(book)
    @book = book
  end

  def as_json
    base_attributes.merge(associations)
  end

  private

  def base_attributes
    {
      id: @book.id, title: @book.title, author: @book.author, isbn: @book.isbn,
      status: @book.status, rating: @book.rating, notes: @book.notes, url: @book.url,
      created_at: @book.created_at.iso8601, updated_at: @book.updated_at.iso8601
    }
  end

  def associations
    { tags: @book.tags.map { |tag| TagSerializer.new(tag, include_count: false).as_json } }
  end
end
