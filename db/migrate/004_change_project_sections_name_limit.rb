class ChangeProjectSectionsNameLimit < ActiveRecord::Migration

    def self.up
        change_column :project_sections, :name, :string, :limit => nil, :null => false
    end

    def self.down
        change_column :project_sections, :name, :string, :limit => 30, :null => false
    end

end
