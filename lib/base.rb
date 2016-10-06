# !usr/bin/ruby
require "highline/import"
require 'pry'
require 'json'

class Pusher
  # Dunno WTF I'm Doing with directories FYI

  def initialize
    @current_dir = current_dir
    cd_into_sallucination_for_file_reading
    get_settings
    change_to_repo_dir
    get_inputs
    cd_and_branch
  end

  def change_to_repo_dir
    Dir.chdir(@current_dir)
  end

  def cd_into_sallucination_for_file_reading
    Dir.chdir('sallucination')
  end

  def get_settings
    settings = File.read('./settings.json')
    @cohorts = JSON.parse(settings)['cohorts']
    @base_solution_url = JSON.parse(settings)['solution_repo']
  end

  def get_inputs
    get_repo
    get_cohorts
    create_solution_repo
    create_student_repo
    create_remote
  end

  def cd_and_branch
    goto_current_working_dir
    goto_repo_dir
    get_branch
    push_branch
  end


  def current_dir
    `pwd`.chomp
  end

  def do_da_prompt(choices, selection_type)
    choose do |menu|
      menu.prompt = "Please choose your #{selection_type}"
      menu.choices(*choices)
    end
  end

  def get_repo
    # Check the directories that are in current directory
    repos = `ls`
    repos = repos.split("\n").map { |repo| repo.to_sym }
    @solution_repo_name = do_da_prompt(repos, 'challenge').to_s
  end

  def get_cohorts
    cohorts = @cohorts.map { |cohort| cohort.to_sym }
    @student_cohort_organization = do_da_prompt(cohorts, 'cohort').to_s
  end

  def get_branch
    branches = list_branches
    branches = branches.split("\n").map { |branch| branch.to_sym }
    # Remove * if on selected branch and extra spaces
    @branch = do_da_prompt(branches, 'branch').to_s.gsub('*', '').strip
  end

  def create_solution_repo
    #creates 'https://github.com/Devbootcamp-atx-Solutions/cheering-mascot-challenge.git'
    @solution_repo_full = @base_solution_url + '/' + @solution_repo_name + '.git'
  end

  def create_student_repo
    #creates  'https://github.com/aus-red-pandas-2016/cheering-mascot-challenge.git'
    @student_repo = 'https://github.com/' + @student_cohort_organization + '/' + @solution_repo_name + '.git'
  end

  def create_remote
    remote_exists = ask('Does a remote exist already locally? Y | N').chomp.downcase
    if remote_exists == 'y'
      # If a remote exists whats it's name locally
      @student_remote_name = @student_cohort_organization
    else
      @student_remote_name = @student_cohort_organization
      add_local_remote
    end
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
    `git branch -a`
  end

  def push_branch
    system "git push #{@student_remote_name} #{@branch}"
  end

end

Pusher.new
