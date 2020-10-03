require_dependency 'projects_helper'

class SectionsController < ApplicationController
    menu_item :projects

    before_action :find_section, :except => :edit
    before_action :find_project, :only => :edit

    helper :projects
    include ProjectsHelper

    def index
        @projects = @section.self_and_descendants.inject([]) do |projects, section|
            projects += params[:closed] ? section.projects : section.projects.active
        end
    end

    def edit
        respond_to do |format|
            format.html { head 406 }
            format.js
        end
    end

private

    def find_section
        if params[:section]
            @section = ProjectSection.find_by_path(params[:section].is_a?(Array) ? params[:section].join('/') : params[:section])
            return if @section
        end
        render_404
    end

end
