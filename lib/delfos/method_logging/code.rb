# frozen_string_literal: true
require_relative "klass_determination"

module Delfos
  module MethodLogging
    class CodeLocation
      include KlassDetermination

      class << self
        def from_caller(stack, caller_binding)
          CallerParsing.new(stack, caller_binding).perform
        end

        def from_called(object, called_method, class_method)
          file, line_number = called_method.source_location
          return unless file && line_number

          new(object, called_method.name.to_s, class_method, file, line_number)
        end

        def method_type_from(class_method)
          class_method ? "ClassMethod" : "InstanceMethod"
        end

        def method_definition_for(klass, class_method, method_name)
          key = key_from(class_method, method_name)

          Delfos::Patching.method_definition_for(klass.to_s,key)
        end

        private

        def key_from(class_method, name)
          "#{method_type_from(class_method)}_#{name}"
        end
      end

      attr_reader :object, :method_name, :class_method, :method_type, :file, :line_number

      def initialize(object, method_name, class_method, file, line_number)
        @object = object
        @method_name = method_name
        @class_method = class_method
        @method_type = self.class.method_type_from class_method
        @file = file
        @line_number = line_number
      end

      def file
        file = @file.to_s

        if file
          Delfos.application_directories.map do |d|
            file = relative_path(file, d)
          end
        end

        file
      end

      def relative_path(file, dir)
        match = dir.to_s.split("/")[0..-2].join("/")

        if file[match]
          file = file.gsub(match, "").
                 gsub(%r{^/}, "")
        end

        file
      end

      def klass
        name = klass_for(object).name || "__AnonymousClass"
        name.tr ":", "_"
      end

      def method_definition_file
        method_definition[0]
      end

      def method_definition_line
        method_definition[1]
      end

      private

      def method_key
        "#{method_type}_#{method_name}"
      end

      def method_definition
        (@method_definition ||= self.class.method_definition_for(klass, class_method, method_name)) || {}
      end
    end

    class CallerParsing
      # This magic number is determined based on the specific implementation now
      # E.g. if the line
      # where we call this `caller_binding.of_caller(stack_index + STACK_OFFSET).eval('self')`
      # is to be extracted into another method we will get a failing test and have to increment
      # the value
      STACK_OFFSET = 5

      attr_reader :stack, :caller_binding

      def initialize(stack, caller_binding)
        @stack = stack
        @caller_binding = caller_binding
      end

      def perform
        file, line_number, method_name = method_details
        return unless current && file && line_number && method_name

        CodeLocation.new(object, method_name.to_s, class_method, file, line_number)
      end

      private

      def class_method
        object.is_a? Module
      end

      def current
        stack.detect do |s|
          file = s.split(":")[0]
          Delfos::MethodLogging.include_file_in_logging?(file)
        end
      end

      def object
        @object ||= caller_binding.of_caller(stack_index + STACK_OFFSET).receiver
      end

      def stack_index
        stack.index { |c| c == current }
      end

      def method_details
        return unless current
        file, line_number, rest = current.split(":")
        method_name = rest[/`.*'$/]
        return unless method_name && file && line_number

        method_name.delete!("`").delete!("'")

        [file, line_number.to_i, method_name]
      end
    end
  end
end
