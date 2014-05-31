class ChangeProjectSectionsIdentifierLimit < ActiveRecord::Migration

    def self.up
        change_column :project_sections, :identifier, :string, :limit => nil, :null => false
    end

    def self.down
        change_column :project_sections, :identifier, :string, :limit => 20, :null => false
    end

end
