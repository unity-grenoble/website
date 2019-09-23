---
layout: publication
date:   2019-06-01
title:  "Distributing Monte Carlo Errors as a Blue Noise in Screen Space by Permuting Pixel Seeds Between Frames"
authors: [
            { name: "Eric Heitz" },
            { name: "Laurent Belcour" },
         ]
conference: "Computer Graphics Forum 2019 (proceedings of EGSR)"
categories: publication
tags: published
thumbnail: "images/thumbnails/publication_distributing_error_blue_noise_animation.png"
---

<p>
<strong>Abstract.</strong>

Recent work has shown that distributing Monte Carlo errors as a blue noise in screen space improves the perceptual quality of rendered images. However, obtaining such distributions remains an open problem with high sample counts and high-dimensional rendering integrals. In this paper, we introduce a temporal algorithm that aims at overcoming these limitations. Our algorithm is applicable whenever multiple frames are rendered, typically for animated sequences or interactive applications. Our algorithm locally permutes the pixel sequences (represented by their seeds) to improve the error distribution across frames. Our approach works regardless of the sample count or the dimensionality and significantly improves the images in low-varying screen-space regions under coherent motion. Furthermore, it adds negligible overhead compared to the rendering times. Note: our supplemental material provides more results with interactive comparisons against previous work.
</p>

