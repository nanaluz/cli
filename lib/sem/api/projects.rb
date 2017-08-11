module Sem
  module API
    class Projects < Base
      def self.list
        org_names = Orgs.list.map { |org| org[:username] }

        org_names.map { |name| list_for_org(name) }.flatten
      end

      def self.list_for_org(org_name)
        projects = api.list_for_org(org_name)

        projects.map { |project| to_hash(project) }
      end

      def self.list_for_team(team_path)
        team = Teams.info(team_path)

        projects = api.list_for_team(team[:id])

        projects.map { |project| to_hash(project) }
      end

      def self.info(path)
        org_name, project_name = path.split("/")

        list_for_org(org_name).find { |project| project[:name] == project_name }
      end

      def self.add_to_team(team_path, project_path)
        project = info(project_path)
        team = Teams.info(team_path)

        api.attach_to_team(project[:id], team[:id])
      end

      def self.remove_from_team(team_path, project_path)
        project = info(project_path)
        team = Teams.info(team_path)

        api.detach_from_team(project[:id], team[:id])
      end

      def self.api
        client.projects
      end

      def self.to_hash(project)
        {
          :id => project.id,
          :name => project.name
        }
      end
    end
  end
end
