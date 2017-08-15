require "spec_helper"

describe Sem::CLI::Teams do
  let(:team) do
    {
      :id => "3bc7ed43-ac8a-487e-b488-c38bc757a034",
      :name => "renderedtext/developers",
      :permission => "write",
      :members => "72",
      :created_at => "2017-08-01 13:14:40 +0200",
      :updated_at => "2017-08-02 13:14:40 +0200"
    }
  end

  describe "#list" do
    let(:another_team) do
      {
        :id => "fe3624cf-0cea-4d87-9dde-cb9ddacfefc0",
        :name => "tb-render/developers",
        :permission => "admin",
        :members => "3"
      }
    end

    before { allow(Sem::API::Teams).to receive(:list).and_return([team, another_team]) }

    it "calls the API" do
      expect(Sem::API::Teams).to receive(:list)

      sem_run("teams:list")
    end

    it "lists the teams" do
      stdout, stderr = sem_run("teams:list")

      msg = [
        "ID                                    NAME                     PERMISSION  MEMBERS",
        "3bc7ed43-ac8a-487e-b488-c38bc757a034  renderedtext/developers  write       72 members",
        "fe3624cf-0cea-4d87-9dde-cb9ddacfefc0  tb-render/developers     admin       3 members"
      ]

      expect(stdout.strip).to eq(msg.join("\n"))
      expect(stderr).to eq("")
    end
  end

  describe "#info" do
    before { allow(Sem::API::Teams).to receive(:info).and_return(team) }

    it "calls the API" do
      expect(Sem::API::Teams).to receive(:info).with("renderedtext/developers")

      sem_run("teams:info renderedtext/developers")
    end

    it "shows information about a team" do
      stdout, stderr = sem_run("teams:info renderedtext/developers")

      msg = [
        "ID          3bc7ed43-ac8a-487e-b488-c38bc757a034",
        "Name        renderedtext/developers",
        "Permission  write",
        "Members     72 members",
        "Created     2017-08-01 13:14:40 +0200",
        "Updated     2017-08-02 13:14:40 +0200"
      ]

      expect(stderr).to eq("")
      expect(stdout.strip).to eq(msg.join("\n"))
    end
  end

  describe "#create" do
    before { allow(Sem::API::Teams).to receive(:create).and_return(team) }

    it "calls the API" do
      expect(Sem::API::Teams).to receive(:create).with("renderedtext", :name => "developers", :permission => "write")

      sem_run("teams:create renderedtext/developers --permission write")
    end

    it "creates a team and displays it" do
      stdout, stderr = sem_run("teams:create renderedtext/developers --permission write")

      msg = [
        "ID          3bc7ed43-ac8a-487e-b488-c38bc757a034",
        "Name        renderedtext/developers",
        "Permission  write",
        "Members     72 members",
        "Created     2017-08-01 13:14:40 +0200",
        "Updated     2017-08-02 13:14:40 +0200"
      ]

      expect(stderr).to eq("")
      expect(stdout.strip).to eq(msg.join("\n"))
    end
  end

  describe "#rename" do
    before { allow(Sem::API::Teams).to receive(:update).and_return(team) }

    it "calls the API" do
      expect(Sem::API::Teams).to receive(:update).with("renderedtext/admins", :name => "developers")

      sem_run("teams:rename renderedtext/admins renderedtext/developers")
    end

    it "changes the team name" do
      stdout, stderr = sem_run("teams:rename renderedtext/developers renderedtext/admins")

      msg = [
        "ID          3bc7ed43-ac8a-487e-b488-c38bc757a034",
        "Name        renderedtext/developers",
        "Permission  write",
        "Members     72 members",
        "Created     2017-08-01 13:14:40 +0200",
        "Updated     2017-08-02 13:14:40 +0200"
      ]

      expect(stderr).to eq("")
      expect(stdout.strip).to eq(msg.join("\n"))
    end
  end

  describe "#set-permission" do
    before { allow(Sem::API::Teams).to receive(:update).and_return(team) }

    it "calls the API" do
      expect(Sem::API::Teams).to receive(:update).with("renderedtext/developers", :permission => "admin")

      sem_run("teams:set-permission renderedtext/developers admin")
    end

    it "sets the permisssion level of the team" do
      stdout, stderr = sem_run("teams:set-permission renderedtext/developers write")

      msg = [
        "ID          3bc7ed43-ac8a-487e-b488-c38bc757a034",
        "Name        renderedtext/developers",
        "Permission  write",
        "Members     72 members",
        "Created     2017-08-01 13:14:40 +0200",
        "Updated     2017-08-02 13:14:40 +0200"
      ]

      expect(stderr).to eq("")
      expect(stdout.strip).to eq(msg.join("\n"))
    end
  end

  describe "#delete" do
    before { allow(Sem::API::Teams).to receive(:delete) }

    it "calls the API" do
      expect(Sem::API::Teams).to receive(:delete).with("renderedtext/old-developers")

      sem_run("teams:delete renderedtext/old-developers")
    end

    it "deletes the team" do
      stdout, stderr = sem_run("teams:delete renderedtext/old-developers")

      msg = [
        "Deleted team renderedtext/old-developers"
      ]

      expect(stderr).to eq("")
      expect(stdout.strip).to eq(msg.join("\n"))
    end
  end

  describe Sem::CLI::Teams::Members do
    describe "#list" do
      let(:user_0) { { :id => "ijovan" } }
      let(:user_1) { { :id => "shiroyasha" } }

      before { allow(Sem::API::Users).to receive(:list_for_team).and_return([user_0, user_1]) }

      it "calls the users API" do
        expect(Sem::API::Users).to receive(:list_for_team).with("renderedtext/cli")

        sem_run("teams:members:list renderedtext/cli")
      end

      it "lists team members" do
        stdout, stderr = sem_run("teams:members:list renderedtext/cli")

        msg = [
          "USERNAME",
          "ijovan",
          "shiroyasha"
        ]

        expect(stderr).to eq("")
        expect(stdout.strip).to eq(msg.join("\n"))
      end
    end

    describe "#add" do
      before { allow(Sem::API::Users).to receive(:add_to_team) }

      it "calls the users API" do
        expect(Sem::API::Users).to receive(:add_to_team).with("renderedtext/developers", "ijovan")

        sem_run("teams:members:add renderedtext/developers ijovan")
      end

      it "add a user to the team" do
        stdout, stderr = sem_run("teams:members:add renderedtext/developers ijovan")

        expect(stderr).to eq("")
        expect(stdout.strip).to eq("User ijovan added to the team.")
      end
    end

    describe "#remove" do
      before { allow(Sem::API::Users).to receive(:remove_from_team) }

      it "calls the users API" do
        expect(Sem::API::Users).to receive(:remove_from_team).with("renderedtext/developers", "ijovan")

        sem_run("teams:members:remove renderedtext/developers ijovan")
      end

      it "removes a user from the team" do
        stdout, stderr = sem_run("teams:members:remove renderedtext/developers ijovan")

        expect(stderr).to eq("")
        expect(stdout.strip).to eq("User ijovan removed from the team.")
      end
    end
  end

  describe Sem::CLI::Teams::Projects do
    describe "#list" do
      let(:project_0) { { :id => "3bc7ed43-ac8a-487e-b488-c38bc757a034", :name => "renderedtext/cli" } }
      let(:project_1) { { :id => "fe3624cf-0cea-4d87-9dde-cb9ddacfefc0", :name => "renderedtext/api" } }

      before { allow(Sem::API::Projects).to receive(:list_for_team).and_return([project_0, project_1]) }

      it "calls the projects API" do
        expect(Sem::API::Projects).to receive(:list_for_team).with("renderedtext/cli")

        sem_run("teams:projects:list renderedtext/cli")
      end

      it "lists projects in the team" do
        stdout, stderr = sem_run("teams:projects:list renderedtext/cli")

        msg = [
          "ID                                    NAME",
          "3bc7ed43-ac8a-487e-b488-c38bc757a034  renderedtext/cli",
          "fe3624cf-0cea-4d87-9dde-cb9ddacfefc0  renderedtext/api"
        ]

        expect(stderr).to eq("")
        expect(stdout.strip).to eq(msg.join("\n"))
      end
    end

    describe "#add" do
      before { allow(Sem::API::Projects).to receive(:add_to_team) }

      it "calls the projects API" do
        expect(Sem::API::Projects).to receive(:add_to_team).with("renderedtext/developers", "renderedtext/cli")

        sem_run("teams:projects:add renderedtext/developers renderedtext/cli")
      end

      it "add a project to the team" do
        stdout, stderr = sem_run("teams:projects:add renderedtext/developers renderedtext/cli")

        expect(stderr).to eq("")
        expect(stdout.strip).to eq("Project renderedtext/cli added to the team.")
      end
    end

    describe "#remove" do
      before { allow(Sem::API::Projects).to receive(:remove_from_team) }

      it "calls the projects API" do
        expect(Sem::API::Projects).to receive(:remove_from_team).with("renderedtext/developers", "renderedtext/api")

        sem_run("teams:projects:remove renderedtext/developers renderedtext/api")
      end

      it "removes a project from the team" do
        stdout, stderr = sem_run("teams:projects:remove renderedtext/developers renderedtext/api")

        expect(stderr).to eq("")
        expect(stdout.strip).to eq("Project renderedtext/api removed from the team.")
      end
    end
  end

  describe Sem::CLI::Teams::SharedConfigs do
    describe "#list" do
      let(:config_0) { { :id => "3bc7ed43-ac8a-487e-b488-c38bc757a034", :name => "renderedtext/aws-tokens" } }
      let(:config_1) { { :id => "fe3624cf-0cea-4d87-9dde-cb9ddacfefc0", :name => "renderedtext/gemfury" } }

      before { allow(Sem::API::SharedConfigs).to receive(:list_for_team).and_return([config_0, config_1]) }

      it "calls the configs API" do
        expect(Sem::API::SharedConfigs).to receive(:list_for_team).with("renderedtext/aws-tokens")

        sem_run("teams:shared-configs:list renderedtext/aws-tokens")
      end

      it "lists shared configurations in the team" do
        stdout, stderr = sem_run("teams:shared-configs:list renderedtext/aws-tokens")

        msg = [
          "ID                                    NAME",
          "3bc7ed43-ac8a-487e-b488-c38bc757a034  renderedtext/aws-tokens",
          "fe3624cf-0cea-4d87-9dde-cb9ddacfefc0  renderedtext/gemfury"
        ]

        expect(stderr).to eq("")
        expect(stdout.strip).to eq(msg.join("\n"))
      end
    end

    describe "#add" do
      before { allow(Sem::API::SharedConfigs).to receive(:add_to_team) }

      it "calls the projects API" do
        expect(Sem::API::SharedConfigs).to receive(:add_to_team).with("rt/developers", "rt/aws-tokens")

        sem_run("teams:shared-configs:add rt/developers rt/aws-tokens")
      end

      it "add a project to the team" do
        stdout, stderr = sem_run("teams:shared-configs:add renderedtext/developers renderedtext/aws-tokens")

        expect(stderr).to eq("")
        expect(stdout.strip).to eq("Shared Configuration renderedtext/aws-tokens added to the team.")
      end
    end

    describe "#remove" do
      before { allow(Sem::API::SharedConfigs).to receive(:remove_from_team) }

      it "calls the projects API" do
        expect(Sem::API::SharedConfigs).to receive(:remove_from_team).with("rt/developers", "rt/tokens")

        sem_run("teams:shared-configs:remove rt/developers rt/tokens")
      end

      it "removes a project from the team" do
        stdout, stderr = sem_run("teams:shared-configs:remove renderedtext/developers renderedtext/aws-tokens")

        expect(stderr).to eq("")
        expect(stdout.strip).to eq("Shared Configuration renderedtext/aws-tokens removed from the team.")
      end
    end
  end
end
