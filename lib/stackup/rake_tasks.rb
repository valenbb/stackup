require "rake/tasklib"

module Stackup

  # Declare Rake tasks for managing a stack.
  #
  class RakeTasks < Rake::TaskLib

    attr_accessor :name
    attr_accessor :stack
    attr_accessor :template
    attr_accessor :parameters

    alias_method :namespace=, :name=

    def initialize(name, template = nil)
      @name = name
      @stack = name
      @template = template
      yield self if block_given?
      fail ArgumentError, "no name provided" unless @name
      fail ArgumentError, "no template provided" unless @template
      define
    end

    def stackup(*rest)
      sh "stackup", stack, *rest
    end

    def define
      namespace(name) do

        up_args = ["-t", template]
        up_deps = [template]

        if parameters
          up_args += ["-p", parameters]
          up_deps += [parameters]
        end

        desc "Update #{stack} stack"
        task "up" => up_deps do
          stackup "up", *up_args
        end

        desc "Cancel update of #{stack} stack"
        task "cancel" do
          stackup "cancel-update"
        end

        desc "Show pending changes to #{stack} stack"
        task "diff" => up_deps do
          stackup "diff", *up_args
        end

        desc "Show #{stack} stack outputs and resources"
        task "inspect" do
          stackup "inspect"
        end

        desc "Delete #{stack} stack"
        task "down" do
          stackup "down"
        end

      end
    end

  end

end