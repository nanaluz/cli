module Sem
  module API
    class Configs < Base
      def self.list
        new.list
      end

      def self.list_for_org(org_name)
        new.list_for_org(org_name)
      end

      def self.list_for_team(team_path)
        new.list_for_team(team_path)
      end

      def list
        org_names = Orgs.list.map { |org| org[:username] }

        org_names.map { |name| list_for_org(name) }.flatten
      end

      def list_for_org(org_name)
        configs = api.list_for_org(org_name)

        configs.map { |config| to_hash(config) }
      end

      def list_for_team(team_path)
        team = Teams.info(team_path)

        configs = api.list_for_team(team[:id])

        configs.map { |config| to_hash(config) }
      end

      private

      def api
        client.shared_configs
      end

      def to_hash(configs)
        {
          :id => configs.id,
          :name => configs.name
        }
      end
    end
  end
end
