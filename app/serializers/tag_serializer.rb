class TagSerializer
  def initialize(tag, include_count: true)
    @tag = tag
    @include_count = include_count
  end

  def as_json
    result = {
      id: @tag.id,
      name: @tag.name,
      created_at: @tag.created_at.iso8601
    }
    result[:books_count] = @tag.books_count if @include_count
    result
  end
end
