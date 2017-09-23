class Sem::API::SharedConfig < SimpleDelegator
  extend Sem::API::Base

  def self.all
    configs = Sem::API::Org.all.pmap { |org| client.shared_configs.list_for_org(org.username) }

    configs.flatten.map { |config| new(config) }
  end

  def self.find!(shared_config_srn)
    org_name, shared_config_name = Sem::SRN.parse_shared_config(shared_config_srn)

    configs = client.shared_configs.list_for_org(org_name)
    config = configs.find { |config| config[:name] == shared_config_name }

    if config.nil?
      raise Sem::Errors::ResourceNotFound.new("Shared Configuration", [org_name, shared_config_name])
    end

    new(selected_shared_config)
  end

  def self.create!(shared_config_srn, args)
    org_name, shared_config_name = Sem::SRN.parse_shared_config(shared_config_srn)

    shared_config = client.shared_configs.create_for_org(org_name, args)

    if shared_config.nil?
      raise Sem::Errors::ResourceNotCreated.new("Shared Configuration", [org_name, args[:name]])
    end

    new(shared_config)
  end

  attr_reader :org_name

  def initialize(org_name, shared_config)
    @org_name = org_name

    super(shared_config)
  end

  def full_name
    "#{org_name}/#{name}"
  end

  def update(args)
    shared_config = api.update(id, args)

    if shared_config.nil?
      raise Sem::Errors::ResourceNotUpdated.new("Shared Configuration", [org_name, shared_config_name])
    end

    new(shared_config)
  end

  def delete!
    api.delete!(id)
  end

  def teams
    client.teams.list_for_shared_config(id).map { |team| Sem::API::Team.new(org_name, team) }
  end

  def projects
    client.project.list_for_shared_config(id).map { |project| Sem::API::Project.new(org_name, project) }
  end

  def files
    client.config_files.list_for_shared_config(id).map { |file| Sem::API::File.new(org_name, file) }
  end

  def env_vars
    client.env_vars.list_for_shared_config(id).map { |env_var| Sem::API::EnvVars.new(org_name, env_var) }
  end

end
