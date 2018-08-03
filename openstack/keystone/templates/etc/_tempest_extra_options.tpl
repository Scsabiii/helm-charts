[auth]
use_dynamic_credentials = true
create_isolated_networks = false
test_accounts_file = /etc/keystone/tempest_accounts.yaml
admin_username = admin
admin_password = {{ .Values.tempest.adminPassword }}
admin_project_name = admin
admin_domain_name = tempest
admin_domain_scope = True
default_credentials_domain_name = tempest

