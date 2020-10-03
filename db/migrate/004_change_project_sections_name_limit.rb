class ChangeProjectSectionsNameLimit < Rails::VERSION::MAJOR < 5 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        change_column :project_sections, :name, :string, :limit => nil, :null => false
    end

    def self.down
        change_column :project_sections, :name, :string, :limit => 30, :null => false
    end

end
