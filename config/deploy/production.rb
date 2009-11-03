#############################################################
#	Application
#############################################################

set :daemon_env, 'production'
set :deploy_to, "/www/daemons/#{application}"
set :host, "prodserver"
server host, :app
