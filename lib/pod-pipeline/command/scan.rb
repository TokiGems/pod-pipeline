require 'pod-pipeline/command/scan/name'
require 'pod-pipeline/command/scan/version'
require 'pod-pipeline/command/scan/remote'
require 'pod-pipeline/command/scan/branch'
require 'pod-pipeline/command/scan/workspace'
require 'pod-pipeline/command/scan/all'

module PPL
    class Command
        class Scan < Command
            self.abstract_command = true

            self.summary = '项目扫描'
            self.description = <<-DESC
                获取项目的关键参数
            DESC

            def initialize(argv)
                super
            end
        end
    end
end