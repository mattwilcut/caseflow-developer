class Github
  APPEALS_PM_URLS = [
    { name: "department-of-veterans-affairs/appeals-pm"}
  ]

  CASEFLOW_URLS = [
    { name: "department-of-veterans-affairs/caseflow"},
    { name: "department-of-veterans-affairs/appeals-deployment"},
    { name: "department-of-veterans-affairs/caseflow-commons"},
    { name: "department-of-veterans-affairs/connect_vbms"},
    { name: "department-of-veterans-affairs/caseflow-feedback"},
    { name: "department-of-veterans-affairs/omniauth-saml-va"},
    { name: "department-of-veterans-affairs/appeals-qa"},
    { name: "department-of-veterans-affairs/ruby-bgs"},
    { name: "department-of-veterans-affairs/caseflow-efolder" }
    
  ]

  def initialize(team)
    @all_issues = []


    if team == 'appeals_pm' || team.nil?
      APPEALS_PM_URLS.each do |repo|
        @all_issues.concat Octokit.list_issues(repo[:name])
      end
    end

    if team == 'caseflow' ||  team.nil?
      CASEFLOW_URLS.each do |repo|
        @all_issues.concat Octokit.list_issues(repo[:name])
      end
    end
    # puts @all_issues
  end

  # def closed_issues
  #   @closed_issues = []
  #   REPOS_URLS.each do |repo|
  #     @closed_issues.concat Octokit.list_issues(repo[:name], state: "closed")
  #   end
  #   @closed_issues
  # end
    
  def in_progress_by_assignee
    issues = issues_by_label
    assignees = assignees_from_issues(issues)

    # This adds a key => [] to store the issues
    assignees.each do |assignee|
      assignee[:full_name] = Octokit.user(assignee[:login]).name
      assignee[:issues] = []
    end
    assignees << { login: "Not Assigned", issues: [] }
    
    issues.each do |issue|
      if !issue[:assignee].nil?
        assignees.each do |assignee|
          if assignee[:login] == issue[:assignee][:login]
            assignee[:issues] << issue
          end
        end
      else
        assignees.each do |assignee|
          if assignee[:login] == "Not Assigned"
            assignee[:issues] << issue
          end
        end
      end
    end

    return assignees
  end

  def issues_by_label
    @all_issues.keep_if do |issue|
      issue[:labels].map(&:name).include?("in progress") || issue[:labels].map(&:name).include?("In Progress")
    end.dup
  end

  private 

  def assignees_from_issues(issues)
    assignees = []
    issues.each do |issue|
      assignees << issue[:assignee] unless issue[:assignee].nil?
    end
    assignees.uniq!(&:login)
    
    return assignees
  end
end