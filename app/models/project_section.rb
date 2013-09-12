class ProjectSection < ActiveRecord::Base
    include Redmine::SafeAttributes

    has_many :projects, :foreign_key => 'section_id'

    acts_as_nested_set :order => 'name', :dependent => :destroy

    before_save :copy_identifier_to_path
    after_move  :update_path

    validates_presence_of :name, :identifier
    validates_uniqueness_of :identifier, :scope => :parent_id
    validates_length_of :name, :maximum => 255
    validates_length_of :identifier, :in => 1..Project::IDENTIFIER_MAX_LENGTH
    validates_format_of :identifier, :with => %r{^(?![0-9]+$)[a-z0-9\-_]*$}, :if => Proc.new { |section| section.identifier_changed? }
    validates_exclusion_of :identifier, :in => %w(new)

    safe_attributes 'name', 'identifier'

    def identifier=(identifier)
        super if new_record?
    end

    # Largely a copy of Project#set_parent!
    def set_parent!(section)
        return if !section.nil? && parent == section
        return unless section.nil? || move_possible?(section)
        siblings = section.nil? ? self.class.roots : section.children
        right_sibling = siblings.detect{ |sibling| sibling.name.to_s.downcase > name.to_s.downcase }
        if right_sibling
            move_to_left_of(right_sibling)
        elsif section.nil?
            if siblings.empty?
                move_to_root
            else
                move_to_right_of(siblings.last) unless self == siblings.last
            end
        else
            move_to_child_of(section)
        end
    end

    def to_path
        self_and_ancestors.collect{ |section| section.identifier }.join('/')
    end

    def to_s
        name
    end

    def css_classes
        classes = 'project'
        classes << ' root' if root?
        classes << ' child' if child?
        classes << (leaf? ? ' leaf' : ' parent')
    end

private

    def copy_identifier_to_path
        self.path = identifier if identifier_changed?
    end

    def update_path
        update_attribute(:path, to_path)
    end

end
