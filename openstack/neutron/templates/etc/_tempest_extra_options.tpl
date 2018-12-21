[DEFAULT]
debug = True
use_stderr = True
rally_debug = True

[auth]
use_dynamic_credentials = False
create_isolated_networks = False
test_accounts_file = /neutron-etc/tempest_accounts.yaml
admin_username = admin
admin_password = {{ .Values.tempestAdminPassword }}
admin_project_name = admin
admin_domain_name = tempest
admin_domain_scope = True
default_credentials_domain_name = tempest

[share]
share_network_id = {{ .Values.tempest.share_network_id }}
alt_share_network_id = {{ .Values.tempest.alt_share_network_id }}
admin_share_network_id = {{ .Values.tempest.admin_share_network_id }}
region = {{ .Values.global.region }}

[identity]
uri_v3 = http://{{ if .Values.global.clusterDomain }}keystone.{{.Release.Namespace}}.svc.{{.Values.global.clusterDomain}}{{ else }}keystone.{{.Release.Namespace}}.svc.kubernetes.{{.Values.global.region}}.{{.Values.global.tld}}{{end}}:5000/v3
endpoint_type = internalURL
v3_endpoint_type = internalURL
region = {{ .Values.global.region }}
default_domain_id = {{ .Values.tempest.domainId }}
admin_domain_scope = True
disable_ssl_certificate_validation = True

[identity-feature-enabled]
domain_specific_drivers = True
project_tags = True
application_credentials = True

[service_available]
manila = False
neutron = True
cinder = False
glance = False
nova = False
swift = False
