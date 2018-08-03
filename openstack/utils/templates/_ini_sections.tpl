{{define "oslo_messaging_rabbit"}}
[oslo_messaging_rabbit]
rabbit_userid = {{ .Values.rabbitmq_user | default .Values.global.rabbitmq_default_user | default "openstack"}}
rabbit_password = {{ .Values.rabbitmq_pass | default .Values.global.rabbitmq_default_pass | default "openstack" }}
rabbit_hosts =  {{include "rabbitmq_host" .}}
rabbit_ha_queues = {{ .Values.rabbitmq_ha_queues | .Values.global.rabbitmq_ha_queues | default "true" }}
rabbit_transient_queues_ttl={{ .Values.rabbit_transient_queues_ttl | .Values.global.rabbit_transient_queues_ttl | default 60 }}
{{end}}

{{- define "ini_sections.database_options" }}
    {{- if or .Values.postgresql.pgbouncer.enabled .Values.global.pgbouncer.enabled }}
max_pool_size = {{ .Values.max_pool_size | default .Values.global.max_pool_size | default 10 }}
max_overflow = -1
    {{- else }}
max_pool_size = {{ .Values.max_pool_size | default .Values.global.max_pool_size | default 5 }}
max_overflow = {{ .Values.max_overflow | default .Values.global.max_overflow | default 10 }}
    {{- end }}
{{- end }}

{{- define "ini_sections.database" }}
[database]
connection = {{ include "db_url" . }}
{{- include "ini_sections.database_options" . }}
{{- end }}

{{- define "ini_sections.audit_middleware_notifications"}}
    {{- if .Values.audit }}
        {{- if .Values.audit.enabled }}
            {{- if .Values.rabbitmq_notifications }}
                {{- if and .Values.rabbitmq_notifications.ports .Values.rabbitmq_notifications.users }}

# this is for the cadf audit messaging
[audit_middleware_notifications]
# topics = notifications
driver = messagingv2
transport_url = rabbit://{{ .Values.rabbitmq_notifications.users.default.user }}:{{ .Values.rabbitmq_notifications.users.default.password | default (tuple . .Values.rabbitmq_notifications.users.default.user | include "rabbitmq.password_for_user")}}@{{ .Chart.Name }}-rabbitmq-notifications:{{ .Values.rabbitmq_notifications.ports.public }}/
mem_queue_size = {{ .Values.audit.mem_queue_size }}
                {{- end }}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}
