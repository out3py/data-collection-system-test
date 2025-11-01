---
layout: home
---

# TEST

# Daily Pages

{% for page in site.pages %}
{% if page.path contains 'daily_pages' %}
- [{{ page.title }}]({{ page.url | relative_url }})
{% endif %}
{% endfor %}