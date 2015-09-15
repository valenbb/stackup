require "set"

module Stackup
  class Stack

    attr_reader :stack, :name, :cf, :template, :monitor
    SUCESS_STATES = ["CREATE_COMPLETE", "UPDATE_COMPLETE"]
    FAILURE_STATES = ["CREATE_FAILED", "DELETE_COMPLETE", "DELETE_FAILED", "UPDATE_ROLLBACK_FAILED", "ROLLBACK_FAILED", "ROLLBACK_COMPLETE", "ROLLBACK_FAILED", "UPDATE_ROLLBACK_COMPLETE", "UPDATE_ROLLBACK_FAILED"]
    END_STATES = SUCESS_STATES + FAILURE_STATES

    def initialize(name, template)
      @cf = Aws::CloudFormation::Client.new
      @stack = Aws::CloudFormation::Stack.new(:name => name, :client => cf)
      @monitor = Stackup::Monitor.new(@stack)
      @template = template
      @name = name
    end

    def create
      response = cf.create_stack(:stack_name => name,
                                 :template_body => template,
                                 :disable_rollback => true)
      stack.wait_until(:max_attempts => 1000, :delay => 10) { |resource| display_events; END_STATES.include?(resource.stack_status) }
      !response[:stack_id].nil?
    end

    def delete
      response = cf.delete_stack(stack_name: name)
      stack.wait_until(:max_attempts => 1000, :delay => 10) { |resource| display_events; END_STATES.include?(resource.stack_status) }
    rescue Aws::CloudFormation::Errors::ValidationError
      puts 'Stack does not exist.'
    end

    def display_events
      monitor.new_events.each do |e|
        ts = e.timestamp.localtime.strftime("%H:%M:%S")
        fields = [e.logical_resource_id, e.resource_status, e.resource_status_reason]
        puts("[#{ts}] #{fields.compact.join(' - ')}")
      end
    end

    def deployed?
      !stack.stack_status.nil?
    rescue Aws::CloudFormation::Errors::ValidationError => e
      false
    end

    def valid?
      response = cf.validate_template(template)
      response[:code].nil?
    end

  end
end
