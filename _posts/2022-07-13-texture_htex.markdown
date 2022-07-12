---
layout: publication
date:   2022-07-12
title:  "Htex: Per-Halfedge Texturing for Abritrary Mesh Topologies"
authors: [
    {name: "Wilhem Barbier"},
    {name: "Jonathan Dupuy"}
]
conference: "HPG 2022"
categories: publication
tags: published
thumbnail: "/images/thumbnails/publication_texture_htex.png"
materials: [
    { type: "url",   name: "webpage", url: "https://onrendering.com" },
    { type: "document", name: "paper", url: "https://onrendering.com/data/papers/htex/htex.pdf" },
    # { type: "document", name: "paper", url: "http://arxiv.org/abs/2206.13112" },
]
---


## Abstract
We introduce per-halfedge texturing (Htex) a GPU-friendly method for texturing arbitrary polygon-meshes without an explicit parameterization. Htex builds upon the insight that halfedges encode an intrinsic triangulation for polygon meshes, where each halfedge spans a unique triangle with direct adjacency information. Rather than storing a separate texture per face of the input mesh as is done by previous parameterization-free texturing methods, Htex stores a square texture for each halfedge and its twin. We show that this simple change from face to halfedge induces two important properties for high performance parameterization-free texturing. First, Htex natively supports arbitrary polygons without requiring dedicated code for, e.g, non-quad faces. Second, Htex leads to a straightforward and efficient GPU implementation that uses only three texture-fetches per halfedge to produce continuous texturing across the entire mesh. We demonstrate the effectiveness of Htex by rendering production assets in real time.
