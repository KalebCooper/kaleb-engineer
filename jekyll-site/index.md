---
layout: default
title: Home
---

# Welcome to Kaleb.Engineer

Software engineer specializing in Swift & iOS development. Building robust applications with modern architectures and clean code principles.

## Latest Posts

<div class="posts-preview">
  {% for post in site.posts limit:3 %}
    <article class="post-preview">
      <h3><a href="{{ post.url }}">{{ post.title }}</a></h3>
      <p class="post-meta">{{ post.date | date: "%B %d, %Y" }}</p>
      <p>{{ post.excerpt | strip_html | truncatewords: 30 }}</p>
    </article>
  {% endfor %}
</div>

## Featured Projects

Coming soon - showcase of Swift and iOS development projects.