# frozen_string_literal: true

require_relative "lib/cinch/version"

Gem::Specification.new do |spec|
  spec.name = "ircinch"
  spec.version = Cinch::VERSION
  spec.authors = ["Matt Sias"]
  spec.email = ["mattsias@gmail.com"]

  spec.summary = "An IRC Bot Building Ruby Framework"
  spec.description = "A simple, friendly Ruby DSL for creating IRC bots"
  spec.homepage = "https://github.com/ircinchrb/ircinch"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ircinchrb/ircinch"
  spec.metadata["changelog_uri"] = "https://github.com/ircinchrb/ircinch/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Register runtime dependencies (gems required to run this gem)
  spec.add_dependency "ostruct"

  # Register development dependencies (gems required to program this gem)
  spec.add_development_dependency "base64"
  spec.add_development_dependency "bundler-audit"
  spec.add_development_dependency "bundler-integrity"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "standard"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
