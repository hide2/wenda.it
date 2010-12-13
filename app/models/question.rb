class Question
  include MongoMapper::Document

  key :title
  key :content
end
