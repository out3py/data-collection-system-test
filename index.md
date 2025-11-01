---
layout: home
---

# TEST

# Daily Pages

{% assign daily_pages_list = site.pages | where_exp: "item", "item.path contains 'daily_pages' or item.url contains '/page_' and item.url contains '.html'" | sort: "title" %}
{% if daily_pages_list.size > 0 %}
{% for page in daily_pages_list %}
- [{{ page.title }}]({{ page.url | relative_url }})
{% endfor %}
{% else %}
No pages found. Total pages: {{ site.pages.size }}
{% for page in site.pages %}
  - {{ page.path }} -> {{ page.url }}
{% endfor %}
{% endif %}