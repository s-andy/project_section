require_dependency 'projects_controller'

module SectionProjectsControllerPatch

    def self.included(base)
        base.send(:include, ProjectSectionHelper)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable

            prepend_before_filter :find_sectioned_project, :only => :show

            before_filter :check_section, :only => :show
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
                if params[:section].is_a?(Array)
                    if @project.section.to_path != params[:section].join('/')
                        redirect_to(sectioned_project_url(@project, params), :status => :moved_permanently)
                    end
                else
                    if @project.section.to_path != params[:section]
                        redirect_to(sectioned_project_url(@project, params), :status => :moved_permanently)
                    end
                end
            end
        end

    end

end
