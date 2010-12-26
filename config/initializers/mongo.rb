MongoMapper.connection = Mongo::Connection.new('localhost', 27017, :pool_size => 5, :timeout => 5)
MongoMapper.database = "wenda"

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    MongoMapper.connection.connect_to_master if forked
  end
end


