module Sem
  module API
    class Teams < Base
      def self.list
        org_names = Sem::API::Orgs.list.map { |org| org[:username] }

        org_names.map { |name| list_for_org(name) }.flatten
      end

      def self.list_for_org(org_name)
        teams = api.list_for_org(org_name)

        teams.map { |team| to_hash(team) }
      end

      def self.info(path)
        org_name, team_name = path.split("/")

        list_for_org(org_name).find { |team| team[:name] == team_name }
      end

      def self.create(org_name, args)
        team = api.create_for_org(org_name, args)

        to_hash(team)
      end

      def self.delete(path)
        id = info(path)[:id]

        api.delete(id)
      end

      def self.api
        client.teams
      end

      def self.to_hash(team)
        {
          :id => team.id,
          :name => team.name,
          :permission => team.permission,
          :members => client.users.list_for_team(team.id).count.to_s,
          :created_at => team.created_at,
          :updated_at => team.updated_at
        }
      end
    end
  end
end
