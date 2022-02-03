+++
title = "Blog about things I care."
date = "2020-11-27T23:17:25+05:30"
author = "Rajesh Rajendran <hey@rjsh.ml>"
authorTwitter = "" #do not include @
cover = ""
tags = ["", ""]
keywords = ["", ""]
description = ""
showFullContent = false
+++

## This is my first blogging endeavour

I've written blogs, usually in blogger. But always wanted to maintain own server, so that I can experiment things in production.
This is one of such experiments. Using git as the source of truth, so that I don't have to mess with dbs. And Hugo as the site generator.
As of now, this blog is powered by
- single node kubernetes cluster ( thanks to CIVO, that they provided free kube cluster based on awesome [k3s](k3s) for free in their #KUBE100 beta program. This is my referral [link](https://www.civo.com/?ref=a6975d), if you want to join in the beta program ).
- Github Action ( to create, publish, and deploy to kube cluster ). Have to change this to GitOps model.
- [Hugo](https://gohugo.io/). The awesome static site generator.
- Awesome Theme, [Hugo Theme Terminal](https://github.com/panr/hugo-theme-terminal)
