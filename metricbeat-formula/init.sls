{% set metricbeat = pillar['metricbeat'] %}

add metricbeat repo:
  pkgrepo.managed:
    - humanname: metricbeat Repo {{ metricbeat['repo'] }}
    - name: deb https://artifacts.elastic.co/packages/{{ metricbeat['repo'] }}/apt stable main
    - file: /etc/apt/sources.list.d/metricbeat.list
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch

install metricbeat:
  pkg.installed:
    - name: metricbeat
    - version: {{ metricbeat['version'] }}
    - hold: {{ metricbeat['hold'] | default(False) }}
    - require:
      - pkgrepo: add metricbeat repo

metricbeat:
  service.running:
    - restart: {{ metricbeat['restart'] | default(True) }}
    - enable: {{ metricbeat['enable'] | default(True) }}
    - require:
      - install metricbeat
    - watch:
      - pkg: metricbeat
      {% if salt['pillar.get']('metricbeat:config', {}) %}
      - file: /etc/metricbeat/metricbeat.yml
      {% endif %}

{% if salt['pillar.get']('metricbeat:config') %}
/etc/metricbeat/metricbeat.yml:
  file.serialize:
    - dataset_pillar: metricbeat:config
    - formatter: yaml
    - user: root
    - group: root
    - mode: 644
    - require:
      - install metricbeat
{% endif %}
