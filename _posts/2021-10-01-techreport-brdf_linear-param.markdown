---
layout: publication
date:   2021-10-01
title:  "Visually-Uniform Reparametrization of Material Appearance through Density Redistribution"
authors: [
            { name: "Pascal Barla" },
            { name: "Laurent Belcour" },
            { name: "Romain Pacanowski" },
         ]
conference: "Technical report 2021"
categories: publication
tags: techreport
thumbnail: "/images/thumbnails/techreport_brdf_linear_space.png"
materials: [
	{ type: "document", name: "article", url: "https://hal.inria.fr/hal-03367475/document" },
]
---

In this work, we tackle the question of how to parameterize a material model (or more generically a model) such that changing one of its parameters will change the output *linearly* for the viewer. If it is possible to measure the amount of visual change for any small change of the parameter, then we show that building a linear parameterization is akin to inverting the cumulative difference function (integral of visual change over the range of the parameter).

<center>
<img width="80%" src="{{ '/images/projects/brdf_linear_space/framework.png' | prepend: site.baseurl }}">
</center>

With this framework and with a proper visual change function, one can linearize any material model's parameters. For example, we provide three example of reparameterization for roughness, edge-tint and sheen.

<center>
<img width="60%" src="{{ '/images/projects/brdf_linear_space/result.png' | prepend: site.baseurl }}">
</center>

But we also show that visual change functions are hard to find. For example, even perceptual metrics that are learned from human subjects do not produce a consistent parameterization depending on the lighting conditions. While this is expected as human perception depends on the frequency content of the illumination, it makes it even harded to build generic linear parameterizations that are based on human vision (if not impossible).