class ProjectSectionsController < ApplicationController
    layout 'admin'
    self.main_menu = false if self.respond_to?(:main_menu)

    before_action :find_parent_section, :only => [ :edit, :update, :destroy ]
    before_action :require_admin

    helper :project_section
    include ProjectSectionHelper

    def index
        @sections = all_sections
    end

    def new
        @section = ProjectSection.new
        @sections = all_sections
    end

    def create
        @section = ProjectSection.new
        @section.safe_attributes = params[:project_section]
        @parent_section = get_parent_section_from_params
        if section_identifier_is_valid? && @section.save
            @section.set_parent!(@parent_section)
            flash[:notice] = l(:notice_successful_create)
            redirect_to(:action => params[:continue] ? 'new' : 'index')
        else
            @sections = all_sections
            render(:action => 'new')
        end
    end

    def edit
        @parent_section = @section.parent
        @sections = all_sections - @section.self_and_descendants
    end

    def update
        @section.safe_attributes = params[:project_section]
        @parent_section = get_parent_section_from_params
        if @section.save
            @section.set_parent!(@parent_section)
            flash[:notice] = l(:notice_successful_update)
            redirect_to(:action => 'index')
        else
            @sections = all_sections - @section.self_and_descendants
            render(:action => 'edit')
        end
    end

    def destroy
        @section.destroy
        redirect_to(:action => 'index')
    end

private

    def all_sections
        ProjectSection.order(:lft)
    end

    def find_parent_section
        @section = ProjectSection.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render_404
    end

    def get_parent_section_from_params
        parent_id = params[:project_section] && params[:project_section][:parent_id]
        if parent_id
            parent = ProjectSection.find_by_id(parent_id)
            return parent if parent
            @section.errors.add(:parent_id, :invalid)
        end
        nil
    end

    # Needed cause parent_id is not yet set at the time of #save
    def section_identifier_is_valid?
        duplicate = ProjectSection.find_by_parent_id_and_identifier(@parent_section, @section.identifier)
        if duplicate
            @section.errors.add(:identifier, :taken)
            false
        else
            true
        end
    end

end
