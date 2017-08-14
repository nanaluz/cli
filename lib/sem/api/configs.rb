module Sem
  module API
    class Configs < Base
      extend Traits::AssociatedWithTeam
      extend Traits::AssociatedWithOrg

      def self.list
        org_names = Orgs.list.map { |org| org[:username] }

        org_names.map { |name| list_for_org(name) }.flatten
      end

      def self.info(path)
        org_name, config_name = path.split("/")

        list_for_org(org_name).find { |config| config[:name] == config_name }
      end

      def self.api
        client.shared_configs
      end

      def self.to_hash(configs)
        {
          :id => configs.id,
          :name => configs.name
        }
      end
    end
  end
end
