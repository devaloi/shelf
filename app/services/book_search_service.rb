# Encapsulates search logic to keep the controller thin and make search
# behavior independently testable. Uses SQLite LIKE for simplicity —
# no external search engine dependency needed at this scale.
class BookSearchService
  def initialize(scope)
    @scope = scope
  end

  def call(query)
    return @scope.none if query.blank?

    sanitized = ActiveRecord::Base.sanitize_sql_like(query)
    @scope.where(
      "title LIKE :q ESCAPE '\\' OR author LIKE :q ESCAPE '\\' OR notes LIKE :q ESCAPE '\\'",
      q: "%#{sanitized}%"
    )
  end
end
