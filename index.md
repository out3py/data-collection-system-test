---
layout: home
---

# TEST

# Daily Pages

{% assign daily_pages_list = site.pages | where_exp: "item", "item.path contains 'daily_pages'" %}
{% if daily_pages_list.size > 0 %}
{% for page in daily_pages_list %}
- [{{ page.title }}]({{ page.url | relative_url }})
{% endfor %}
{% else %}
No pages found. Total pages: {{ site.pages.size }}
{% endif %}