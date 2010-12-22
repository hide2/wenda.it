class User
  include MongoMapper::Document

  key :name,        String
  key :password,    String
  key :email,       String
  key :avatar_path, String
  
  many :questions
  many :answers
  many :badges
end
