require_dependency 'projects_helper'

class SectionsController < ApplicationController
    before_filter :find_section

    helper :projects
    include ProjectsHelper

    def index
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
