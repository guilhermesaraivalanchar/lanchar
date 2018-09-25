set :stage, :production
server '159.65.46.254', user: 'deploy', roles: %w{app db web}
