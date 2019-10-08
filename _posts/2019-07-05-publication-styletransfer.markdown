---
layout: publication
date:   2019-07-05
title:  "Multi-Stylization of Video Games in Real-Time guided by G-buffer Information"
authors: [
            { name: "Adèle Saint-Denis" },
            { name: "Kenneth Vanhoey" },
			{ name: "Thomas Deliot" }
         ]
conference: "High Performance Graphics 2019 - Posters"
categories: publication
tags: published
thumbnail: "/images/thumbnails/poster_HPG2019.png"
materials: [
    { type: "url",   name: "webpage", url: "http://kvanhoey.eu/index.php?page=research&lang=en#HPG19poster" },
    { type: "document", name: "pdf", url: "http://kenneth.vanhoey.free.fr/data/research/poster_HPG2019.pdf" }
]
---

<p>
<strong>Abstract.</strong>
We investigate how to take advantage of modern neural style transfer techniques to modify the style of video games at runtime. Recent style transfer neural networks are pre-trained, and allow for fast style transfer of any style at runtime. However, a single style applies globally, over the full image, whereas we would like to provide finer authoring tools to the user. In this work, we allow the user to assign styles (by means of a style image) to various physical quantities found in the G-buffer of a deferred rendering pipeline, like depth, normals, or object ID. Our algorithm then interpolates those styles smoothly according to the scene to be rendered: e.g., a different style arises for different objects, depths, or orientations. 
</p>

