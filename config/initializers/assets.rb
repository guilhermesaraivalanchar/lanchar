# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

config = Rails.application.config

config.assets.paths << Rails.root.join('vendor', 'assets')
config.assets.paths << Rails.root.join('vendor', 'assets', 'plugins')
config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets')
config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets', 'css')
config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets', 'scss')

config.assets.precompile += %w( custom.js )
config.assets.precompile += %w( users.js )
config.assets.precompile += %w( produtos.js )
config.assets.precompile += %w( tipo_users.js )