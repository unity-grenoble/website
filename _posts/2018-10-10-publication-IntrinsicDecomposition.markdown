---
layout: publication
date:   2018-10-10
title:  "Unsupervised Deep Single-Image Intrinsic Decomposition using Illumination-Varying Image Sequences"
authors: [
            { name: "Louis Lettry" },
            { name: "Kenneth Vanhoey" },
			{ name: "Luc Van Gool" }
         ]
conference: Pacific Graphics 2018
categories: publication
tags: published
thumbnail: "/images/thumbnails/publication_IntrinsicDecomp.png"
materials: [
    { type: "url",   name: "webpage", url: "http://kenneth.vanhoey.free.fr/index.php?page=research&lang=en#LVvG18b" },
    { type: "document", name: "pdf", url: "http://kenneth.vanhoey.free.fr/data/research/LVvG18b.pdf" },
    { type: "code",  name: "code",  url: "https://github.com/kvanhoey/UnsupervisedIntrinsicDecomposition" },
    { type: "document", name: "supp. pdf", url: "http://kenneth.vanhoey.free.fr/data/research/LVvG18b_supplemental.zip" },
    { type: "slides",  name: "slides",  url: "https://docs.google.com/presentation/d/13E5Tog95OU4xokwIb_GZxIvQJ3h0B1AdMbiiMYmsdJo/" }

]
bibtex: "@article{LVvG18b,\n
author = {Lettry, L. and Vanhoey, K. and Van Gool, L.},\n
title = {Unsupervised Deep Single-Image Intrinsic Decomposition using Illumination-Varying Image Sequences},\n
journal = {Computer Graphics Forum},\n
volume = {37},\n
number = {7},\n
pages = {409-419},\n
doi = {10.1111/cgf.13578},\n
url = {https://onlinelibrary.wiley.com/doi/abs/10.1111/cgf.13578},\n
eprint = {https://onlinelibrary.wiley.com/doi/pdf/10.1111/cgf.13578}
}"
---

<p>
<strong>Abstract.</strong>
Machine learning based Single Image Intrinsic Decomposition (SIID) methods decompose a captured scene into its albedo and shading images by using the knowledge of a large set of known and realistic ground truth decompositions. Collecting and annotating such a dataset is an approach that cannot scale to sufficient variety and realism. We free ourselves from this limitation by training on unannotated images. Our method leverages the observation that two images of the same scene but with different lighting provide useful information on their intrinsic properties: by definition, albedo is invariant to lighting conditions, and cross-combining the estimated albedo of a first image with the estimated shading of a second one should lead back to the second one’s input image. We transcribe this relationship into a siamese training scheme for a deep convolutional neural network that decomposes a single image into albedo and shading. The siamese setting allows us to introduce a new loss function including such cross-combinations, and to train solely on (time-lapse) images, discarding the need for any ground truth annotations. As a result, our method has the good properties of i) taking advantage of the time-varying information of image sequences in the (pre-computed) training step, ii) not requiring ground truth data to train on, and iii) being able to decompose single images of unseen scenes at runtime. To demonstrate and evaluate our work, we additionally propose a new rendered dataset containing illumination-varying scenes and a set of quantitative metrics to evaluate SIID algorithms. Despite its unsupervised nature, our results compete with state of the art methods, including supervised and non data-driven methods. 
</p>
