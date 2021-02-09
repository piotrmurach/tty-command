source "https://rubygems.org"

gemspec

gem "json", "2.4.1" if RUBY_VERSION == "2.0.0"

group :test do
  gem "simplecov", "~> 0.16.1"
  gem "coveralls", "~> 0.8.22"
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.1.0")
group :perf do
  gem "memory_profiler", "~> 0.9.8"
end
end
