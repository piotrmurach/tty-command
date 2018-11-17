source 'https://rubygems.org'

gemspec

group :test do
  gem 'simplecov', '~> 0.16.1'
  gem 'coveralls', '~> 0.8.22'
end

if RUBY_VERSION > '2.1.0'
  group :perf do
    gem 'memory_profiler', '~> 0.9.8'
  end
end
