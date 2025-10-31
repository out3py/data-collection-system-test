---
layout: home
---

# TEST

# Daily Pages

{% assign daily_pages = site.pages | where_exp: "page", "page.path contains 'daily_pages'" | sort: "path" | reverse %}
{% for page in daily_pages limit: 50 %}
  {% assign url_parts = page.path | split: '/' %}
  {% assign dir_name = url_parts[1] %}
  {% assign file_name = url_parts[2] | remove: '.md' %}
  {% assign html_url = dir_name | append: '/' | append: file_name | append: '.html' %}
- [{{ page.title }}]({{ html_url }})
{% endfor %}