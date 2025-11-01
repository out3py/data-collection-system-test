---
layout: home
---

# TEST

# Daily Pages

{% assign daily_pages_list = site.pages | where_exp: "item", "item.path contains 'daily_pages'" %}
{% for page in daily_pages_list %}
- [{{ page.title }}]({{ page.url | relative_url }})
{% endfor %}