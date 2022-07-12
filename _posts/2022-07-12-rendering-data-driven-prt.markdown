---
layout: publication
date:   2022-07-12
title:  "A Data-Driven Paradigm for Precomputed Radiance Transfer"
authors: [
    {name: "Laurent Belcour"},
    {name: "Thomas Deliot"},
    {name: "Wilhem Barbier"},
    {  
        name: "Cyril Soler",
        url: "https://maverick.inria.fr/Members/Cyril.Soler/",
        affiliation: "Inria"
    }
]
conference: "HPG 2022"
categories: publication
tags: published
thumbnail: "/images/thumbnails/publication_rendering_data_driven_prt.png"
materials: [
    { type: "document", name: "paper",    url: "http://arxiv.org/abs/2206.13112" },
    { type: "url",      name: "notebook", url: "https://belcour.github.io/blog/supp/2022-data-driven-prt/index.html" },
]
---

## Abstract
In this work, we explore a change of paradigm to build *Precomputed Radiance Transfer* (PRT) methods in a data-driven way. This paradigm shift allows us to alleviate the difficulties of building traditional PRT methods such as defining a reconstruction basis, coding a dedicated path tracer to compute a transfer function, etc. Our objective is to pave the way for Machine Learned methods by providing a simple baseline algorithm. More specifically, we demonstrate real-time rendering of indirect illumination in hair and surfaces from a few measurements of direct lighting. We build our baseline from pairs of direct and indirect illumination renderings using only standard tools such as Singular Value Decomposition (SVD) to extract both the reconstruction basis and transfer function.
