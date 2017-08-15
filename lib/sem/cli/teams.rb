class Sem::CLI::Teams < Sem::ThorExt::SubcommandThor
  namespace "teams"

  desc "list", "list teams"
  def list
    teams = Sem::API::Teams.list

    Sem::Views::Teams.list(teams)
  end

  desc "info", "show information about a team"
  def info(name)
    team = Sem::API::Teams.info(name)

    Sem::Views::Teams.info(team)
  end

  desc "create", "create a new team"
  method_option :permission, :default => "read",
                             :aliases => "-p",
                             :desc => "Permission level of the team in the organization"
  def create(name)
    org_name, team_name = name.split("/")

    team = Sem::API::Teams.create(org_name,
                                  :name => team_name,
                                  :permission => options["permission"])

    Sem::Views::Teams.info(team)
  end

  desc "rename", "change the name of the team"
  def rename(old_name, new_name)
    _, name = new_name.split("/")

    team = Sem::API::Teams.update(old_name, :name => name)

    Sem::Views::Teams.info(team)
  end

  desc "set-permission", "set the permission level of the team"
  def set_permission(team_name, permission)
    team = Sem::API::Teams.update(team_name, :permission => permission)

    Sem::Views::Teams.info(team)
  end

  desc "delete", "removes a team from your organization"
  def delete(name)
    Sem::API::Teams.delete(name)

    puts "Deleted team #{name}"
  end

  class Members < Sem::ThorExt::SubcommandThor
    namespace "teams:members"

    desc "list", "lists members of the team"
    def list(team_name)
      members = Sem::API::Users.list_for_team(team_name)

      Sem::Views::Users.list(members)
    end

    desc "add", "add a user to the team"
    def add(team_name, username)
      Sem::API::Users.add_to_team(team_name, username)

      puts "User #{username} added to the team."
    end

    desc "remove", "removes a user from the team"
    def remove(team_name, username)
      Sem::API::Users.remove_from_team(team_name, username)

      puts "User #{username} removed from the team."
    end
  end

  class Projects < Sem::ThorExt::SubcommandThor
    namespace "teams:projects"

    desc "list", "lists projects in a team"
    def list(team_name)
      projects = Sem::API::Projects.list_for_team(team_name)

      print_table(Sem::CLI::Projects.instances_table(projects))
    end

    desc "add", "add a project to a team"
    def add(team_name, project_name)
      Sem::API::Projects.add_to_team(team_name, project_name)

      puts "Project #{project_name} added to the team."
    end

    desc "remove", "removes a project from the team"
    def remove(team_name, project_name)
      Sem::API::Projects.remove_from_team(team_name, project_name)

      puts "Project #{project_name} removed from the team."
    end
  end

  class SharedConfigs < Sem::ThorExt::SubcommandThor
    namespace "teams:shared-configs"

    desc "list", "list shared configurations in a team"
    def list(team_name)
      configs = Sem::API::SharedConfigs.list_for_team(team_name)

      print_table(Sem::CLI::SharedConfigs.instances_table(configs))
    end

    desc "add", "add a shared configuration to a team"
    def add(team_name, shared_config_name)
      Sem::API::SharedConfigs.add_to_team(team_name, shared_config_name)

      puts "Shared Configuration #{shared_config_name} added to the team."
    end

    desc "remove", "removes a project from the team"
    def remove(team_name, shared_config_name)
      Sem::API::SharedConfigs.remove_from_team(team_name, shared_config_name)

      puts "Shared Configuration #{shared_config_name} removed from the team."
    end
  end

  desc "members", "manage team members", :hide => true
  subcommand "members", Members

  desc "projects", "manage team members", :hide => true
  subcommand "projects", Projects

  desc "shared_configs", "manage shared configurations", :hide => true
  subcommand "shared_configs", SharedConfigs
end
