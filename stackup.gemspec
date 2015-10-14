lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "stackup/version"

Gem::Specification.new do |spec|

  spec.name          = "stackup"
  spec.version       = Stackup::VERSION
  spec.authors       = ["Mike Williams", "Arvind Kunday"]
  spec.email         = ["mike.williams@rea-group.com", "arvind.kunday@rea-group.com"]
  spec.summary       = "Manage CloudFormation stacks"
  spec.homepage      = "https://github.com/realestate-com-au/stackup"
  spec.license       = "MIT"

  spec.files         = Dir["**/*"].reject { |f| File.directory?(f) }
  spec.executables   = spec.files.grep(/^bin/) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "aws-sdk", "~> 2.0"
  spec.add_dependency "clamp", "~> 1.0"
  spec.add_dependency "console_logger"
  spec.add_dependency "multi_json"

end
