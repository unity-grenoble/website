---
layout: publication
date:   2017-08-01
title:  "A Practical Extension to Microfacet Theory for the Modeling of Varying Iridescence"
authors: [
            { name: "Laurent Belcour" },
            { name: "Pascal Barla", affiliation: "Inria Bordeaux", url: "" }
         ]
conference: ACM SIGGRAPH 2017
categories: publication
tags: published
thumbnail: "/images/thumbnails/publication_brdf_thin_film.png"
materials: [
    { type: "url",   name: "webpage", url: "https://belcour.github.io/blog/research/2017/05/01/brdf-thin-film.html" },
    { type: "video", name: "video", url: "https://www.youtube.com/watch?v=4nKb9hRYbPA&feature=youtu.be" },
    { type: "document", name: "pdf", url: "https://hal.inria.fr/hal-01518344/document" },
    { type: "document", name: "supp. pdf", url: "https://hal.inria.fr/hal-01518344v2/file/supp-mat-small%20%281%29.pdf" },
    { type: "code",  name: "code",  url: "https://hal.inria.fr/hal-01518344v2/file/supplemental-code%20%282%29.zip" },
    { type: "slides",  name: "slides",  url: "https://belcour.github.io/blog/slides/2017-brdf-thin-film/slides.html" },
]
bibtex: "@article{belcour2017,\n
    title = {{A Practical Extension to Microfacet Theory for the Modeling of Varying Iridescence}},\n
    author = {Belcour, Laurent and Barla, Pascal},\n
    journal = {{ACM Transactions on Graphics}},\n
    volume = {36},\n
    number = {4},\n
    pages = {65},\n
    year = {2017},\n
    month = Jul,\n
}"
---

<p>
<strong>Abstract.</strong>

Thin film iridescence permits to reproduce the appearance of leather. However, this theory requires spectral rendering engines (such as Maxwell Render) to correctly integrate the change of appearance with respect to viewpoint (known as goniochromatism). This is due to aliasing in the spectral domain as real-time renderers only work with three components (RGB) for the entire range of visible light. In this work, we show how to anti-alias a thin-film model, how to incorporate it in microfacet theory, and how to integrate it in a real-time rendering engine. This widens the range of reproducible appearances with microfacet models.
</p>

<p>
<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/4nKb9hRYbPA" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>
</p>

<p>
<strong>Implementations.</strong>

This work is used in Unity's <a href="https://blogs.unity3d.com/2018/03/16/the-high-definition-render-pipeline-focused-on-visual-quality/">HD rendering pipeline</a>. Also, this work was implemented by users of <a href="https://github.com/cCharkes/Iridescence">Unity</a>, <a href="http://polycount.com/discussion/comment/2604578/#Comment_2604578">Unreal</a>, <a href="https://docs.cryengine.com/display/RN/CRYENGINE+5.6.0">CryEngine</a> and <a href="https://blenderartists.org/forum/showthread.php?433309-Micro-angle-dependent-Roughness-amp-Iridescence/page14">Blender</a>.
</p>
