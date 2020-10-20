---
layout: demo
date:   2020-10-16
title:  "Texture synthesis with histogram-preserving blending"
authors: [
            { name: "Thomas Deliot"},
            { name: "Eric Heitz"},
            { name: "Fabrice Neyret", affiliation: "CNRS/Inria", url: "http://evasion.imag.fr/Membres/Fabrice.Neyret/"}
         ]
categories: demo
thumbnail: "/images/thumbnails/demo_texture_synthesis.png"
include_url: by_example_texture_demo.html
---

Use this tool to synthesize a new texture of arbitrary size from a provided example stochastic texture, by splatting random tiles of the input to the output using <a href="https://eheitzresearch.wordpress.com/722-2/">histogram-preserving blending</a>. It works on all random-phase inputs, as well as on many non-random-phase inputs which are stochastic and non-periodic, typically natural textures such as moss, granite, sand, bark, etc.
<br />
<ul>
  <li><a href="https://hal.inria.fr/hal-01824773/document">High-Performance By-Example Noise using a Histogram-Preserving Blending Operator</a>, HPG 2018</li>
  <li><a href="https://drive.google.com/file/d/1QecekuuyWgw68HU9tg6ENfrCTCVIjm6l/view">Procedural Stochastic Textures by Tiling and Blending</a>, GPU Zen 2</li>
</ul>