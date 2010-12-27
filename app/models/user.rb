class User
  include MongoMapper::Document

  key :name,              String
  key :salt,              String
  key :crypted_password,  String
  key :email,             String
  key :avatar_path,       String
  timestamps!
  
  many :questions
  many :answers
  many :badges
  
  def password=(pass)
    salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
    self.salt, self.crypted_password = salt, Digest::SHA256.hexdigest(pass + salt)
  end

  def self.authenticate(name, password)
    user = User.find_by_name(name)
    if user.nil?
      return nil
    elsif Digest::SHA256.hexdigest(password + user.salt) != user.crypted_password
      return nil
    end
    user
  end
  
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
