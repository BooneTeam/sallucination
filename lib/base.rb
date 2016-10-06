# !usr/bin/ruby
require "highline/import"
require 'pry'
require 'json'

class Pusher


  def initialize
    # Dunno WTF I'm Doing with directories
    @current_dir = `pwd`.chomp
    Dir.chdir('sallucination')

    settings = File.read('./settings.json')
    @cohorts = JSON.parse(settings)['cohorts']

    @base_solution_url = 'https://github.com/Devbootcamp-atx-Solutions'
    Dir.chdir(@current_dir)
    get_inputs
    cd_and_branch
  end

  def get_repo
    # Check the directories that are in current directory
    repos = `ls`
    repos = repos.split("\n").map{|repo| repo.to_sym}
    solution_selected = choose do |menu|
      menu.prompt = "Please choose your a challenge repo?  "
      menu.choices(*repos)
    end
    @solution_repo_name = solution_selected.to_s
  end

  def get_cohorts
    cohorts = @cohorts.map{|cohort| cohort.to_sym}
    cohort_selected = choose do |menu|
      menu.prompt = "Please choose your a cohort org"
      menu.choices(*cohorts)
    end
    # ie: aus-red-pandas-2016
    @student_cohort_organization = cohort_selected.to_s
  end

  def create_solution_repo
    #creates 'https://github.com/Devbootcamp-atx-Solutions/cheering-mascot-challenge.git'
    @solution_repo_full   = @base_solution_url + '/' +  @solution_repo_name + '.git'
  end

  def create_student_repo
    #creates  'https://github.com/aus-red-pandas-2016/cheering-mascot-challenge.git'
    @student_repo = 'https://github.com/' + @student_cohort_organization + '/' + @solution_repo_name + '.git'
  end

  def create_remote
    remote_exists = ask('does a remote exist already locally? Y | N').chomp.downcase
    if remote_exists == 'y'
      # If a remote exists whats it's name locally
      @student_remote_name  = @student_cohort_organization
    else
      @student_remote_name  = @student_cohort_organization
      add_local_remote
    end
  end

  def get_inputs
    get_repo
    get_cohorts
    create_solution_repo
    create_student_repo
    create_remote
  end

  def add_local_remote
    Dir.chdir("#{@solution_repo_name}")
    system "git remote add #{@student_remote_name} #{@student_repo}"
  end

  def goto_current_working_dir
    Dir.chdir("#{@current_dir}")
  end

  def goto_repo_dir
    Dir.chdir("#{@solution_repo_name}")
  end

  def list_branches
    # what branch do you wanna push over there to the students ie: gb-solution
    branches = `git branch -a`
  end

  def select_branch
    branches = list_branches
    branches = branches.split("\n").map{|branch| branch.to_sym}
    branch_selected = choose do |menu|
      menu.prompt = "Please choose your a branch "
      menu.choices(*branches)
    end
    # Remove * if on selected branch and extra spaces
    @branch = branch_selected.to_s.gsub('*','').strip
  end

  def push_branch
    system "git push #{@student_remote_name} #{@branch}"
  end

  def cd_and_branch
    goto_current_working_dir
    goto_repo_dir
    select_branch
    push_branch
  end

end

Pusher.new
