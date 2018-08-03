# Defines configuration options specific for Arista ML2 Mechanism driver

[ml2_arista]
{{- range $k,$v := .Values.arista }}
  {{- if and (ne "switches" $k) (ne "physnet" $k) }}
{{ $k }} = {{ $v }}
  {{- end }}
{{- end }}
{{- if .Values.arista.physnet }}
managed_physnets = {{ .Values.arista.physnet }}
{{- end }}

region_name = {{ .Values.global.region }}
switch_info = {{ range $i, $switch := .Values.arista.switches }}
  {{- $switch.host }}:{{ $switch.user }}:{{ $switch.password | urlquery -}}
  {{- if lt $i (sub (len $.Values.arista.switches) 1) }},{{ end -}}
{{- end }}
