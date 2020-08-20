---
layout: publication
date:   2019-08-01
title:  "A Low-Discrepancy Sampler that Distributes Monte Carlo Errors as a Blue Noise in Screen Space"
authors: [
            { name: "Eric Heitz" },
            { name: "Laurent Belcour" },
            { name: "Victor Ostromoukhov", affiliation: "LIRIS", url: "" },
            { name: "David Coeurjolly", affiliation: "LIRIS", url: "" },
            { name: "Jean-Claude Iehl", affiliation: "LIRIS", url: "" }
         ]
conference: ACM SIGGRAPH Talks 2019
categories: publication
tags: published
thumbnail: "/images/thumbnails/publication_screen_space_sampler_blue_noise.png"
materials: [
    { type: "document", name: "abstract", url: "https://hal.archives-ouvertes.fr/hal-02150657/document" },
    { type: "document", name: "supp. doc", url: "https://hal.archives-ouvertes.fr/hal-02150657/file/supplemental.zip" },
    { type: "code", name: "code", url: "https://hal.archives-ouvertes.fr/hal-02150657/file/samplerCPP.zip" },
    { type: "code", name: "unity demo", url: "https://drive.google.com/file/d/181AXka1ntceVsKIJ_ZD51V3iYeq2szYP/view?usp=sharing" },
    { type: "url", name: "supp. html", url: "https://belcour.github.io/supp/2019-sampling-bluenoise/index.html"},
    { type: "video", name: "video", url: "https://hal.archives-ouvertes.fr/hal-02150657/file/samplerBlueNoiseErrors2019_video.mp4"},
    { type: "slides", name: "slides", url: "https://belcour.github.io/blog/slides/2020-brdf-fresnel-decompo/index.html"},  
]
---

<p>
<strong>Abstract.</strong>

We introduce a sampler that generates per-pixel samples achieving high visual quality thanks to two key properties related to the Monte Carlo errors that it produces. First, the sequence of each pixel is an Owen-scrambled Sobol sequence that has state-of-the-art convergence properties. The Monte Carlo errors have thus low magnitudes. Second, these errors are distributed as a blue noise in screen space. This makes them visually even more acceptable. Our sam-pler is lightweight and fast. We implement it with a small texture and two xor operations. Our supplemental material provides comparisons against previous work for different scenes and sample counts.
</p>

