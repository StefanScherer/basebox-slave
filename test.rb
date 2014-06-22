require 'vcloud-rest/connection'
require 'awesome_print'

server   = "https://roecloud001"
username = "vagrant"
password = "MySecretPass"
orgname  = "SS"

conn = VCloudClient::Connection.new(server, username, password, orgname, "5.1")
conn.login
orgs = conn.get_organizations
ap orgs

org = conn.get_organization(orgs[orgname])
ap org

