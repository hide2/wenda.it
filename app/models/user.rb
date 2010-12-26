class User
  include MongoMapper::Document

  key :name,        String
  key :password,    String
  key :email,       String
  key :avatar_path, String
  timestamps!
  
  many :questions
  many :answers
  many :badges
  
  def self.recent(limit = LIMIT)
    all(:limit => limit, :order => "created_at DESC")
  end
  
  def self.paginate(page = 1, limit = 35)
    raise "Wrong page" if page.to_i < 1
    all(:limit => limit, :offset => (page.to_i-1)*limit, :order => "created_at DESC")
  end
  
  def self.search(keyword)
    all(:name => /#{keyword}/, :limit => 35, :order => "created_at DESC")
  end
  
end
