require_dependency 'projects_controller'

module SectionProjectsControllerPatch

    def self.included(base)
        base.send(:include, ProjectSectionHelper)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            prepend_before_action :find_sectioned_project, :only => :show

            before_action :check_section, :only => :show
        end
    end

    module InstanceMethods

        def find_sectioned_project
            if params[:section]
                if params[:section].is_a?(Array)
                    params[:id] = params[:section].pop
                else
                    sections = params[:section].split('/')
                    params[:id] = sections.pop
                    params[:section] = sections.join('/')
                end
            end
        end

        def check_section
            if params[:section]
                section_path = params[:section].is_a?(Array) ? params[:section].join('/') : params[:section]
                if @project.section.to_path != section_path
                    args = params.respond_to?(:to_unsafe_hash) ? params.to_unsafe_hash : params
                    redirect_to(sectioned_project_url(@project, args.except(:protocol, :host, :only_path)), :status => :moved_permanently)
                end
            end
        end

    end

end
