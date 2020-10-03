class ChangeProjectSectionsIdentifierLimit < Rails::VERSION::MAJOR < 5 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]

    def self.up
        change_column :project_sections, :identifier, :string, :limit => nil, :null => false
    end

    def self.down
        change_column :project_sections, :identifier, :string, :limit => 20, :null => false
    end

end
