---
layout: demo
date:   2020-10-16
title:  "Texture synthesis with histogram-preserving blending"
authors: [
            { name: "Thomas Deliot"},
            { name: "Eric Heitz"},
            { name: "Fabrice Neyret", affiliation: "CNRS/Inria"}
         ]
categories: demo
thumbnail: "/images/thumbnails/demo_texture_synthesis.png"
include_url: by_example_texture_demo.html
---

Use this tool to synthesize a new texture of arbitrary size from a provided example stochastic texture, by splatting random tiles of the input to the output with histogram-preserving blending. It works on all random-phase inputs, as well as on many non-random-phase inputs which are stochastic and non-periodic, typically natural textures such as moss, granite, sand, bark, etc.
