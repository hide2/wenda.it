class Tag
  include MongoMapper::Document

  key :name,            String
  key :questions_count, Integer, :default => 1
  
end
