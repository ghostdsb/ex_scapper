defmodule ExScapper.Templater do

  def make_post(data) do
'''
---
layout: post-euler
title:  "Project Euler Solution #{data["question_number"]}"
date:   #{data["last-modified"]}
category: Euler
---

#{data["question"]["title"]}
#{data["question"]["content"]}

### Solution

{% highlight python %}
#{data["answer"]}
{% endhighlight %}
'''
  end
end
