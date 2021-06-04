---
layout: publication
date:   2021-01-25
title:  "A Sliced Wasserstein Loss for Neural Texture Synthesis"
authors: [
            { name: "Eric Heitz" },
            { name: "Kenneth Vanhoey" },
            { name: "Thomas Chambon" },
            { name: "Laurent Belcour" },
         ]
conference: "CVPR 2021"
categories: publication
tags: published
thumbnail: "/images/thumbnails/publication_sliced_wasserstein_loss.png"
materials: [
    { type: "url",   name: "article", url: "https://arxiv.org/pdf/2006.07229.pdf" },
    { type: "video", name: "video", url: "https://youtu.be/sxtjexgRhm4" },
		{ type: "document",  name: "poster",  url: "http://kvanhoey.eu/data/research/HVCB21-poster.pdf" },
    { type: "code",  name: "code",  url: "https://github.com/tchambon/A-Sliced-Wasserstein-Loss-for-Neural-Texture-Synthesis" },

]
---

<p>
<strong>Abstract.</strong>
We address the problem of computing a textural loss based on the statistics extracted from the feature activations of a convolutional neural network optimized for object recognition (e.g. VGG-19). The underlying mathematical problem is the measure of the distance between two distributions in feature space. The Gram-matrix loss is the ubiquitous approximation for this problem but it is subject to several shortcomings. Our goal is to promote the Sliced Wasserstein Distance as a replacement for it. It is theoretically proven, practical, simple to implement, and achieves results that are visually superior for texture synthesis by optimization or training generative neural networks. 
</p>

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/sxtjexgRhm4" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe>
</center>
