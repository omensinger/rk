Gem::Specification.new do |g|
  g.name = "rk"
  g.version = "1.1.0"
  g.summary = "Redis key builder"
  g.description = "Ruby helper to generate keys for Redis"
  g.authors = ["Oliver Mensinger"]
  g.email = "oliver.mensinger@gmail.com"
  g.files = %w[lib/global_call.rb lib/rk.rb]
  g.homepage = "https://github.com/omensinger/rk"
  g.license = "MIT"

  g.add_development_dependency "minitest"
end
