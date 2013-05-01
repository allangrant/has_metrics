ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

# ActiveRecord::Migrator.up "db/migrate"

def create_tables_for(model = :user)
  ActiveRecord::Migration.create_table "#{model}s", :force => true do |t|
    t.string   "name"
  end
  ActiveRecord::Migration.create_table "#{model}_metrics", :force => true
end
