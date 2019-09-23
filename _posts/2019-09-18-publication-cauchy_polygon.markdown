---
layout: publication
date:   2019-09-18
title:  "Integration and Simulation of Bivariate Projective-Cauchy Distributions within Arbitrary Polygonal Domains"
authors: [
            { name: "Jonathan Dupuy" },
            { name: "Laurent Belcour" },
			{ name: "Eric Heitz" }
         ]
conference: Technical report 2019
categories: publication
tags: techreport
thumbnail: "/images/thumbnails/publication_cauchy_polygon.png"
materials: [
    { type: "url",   name: "arxiv", url: "https://arxiv.org/abs/1909.07605" },
    { type: "video", name: "video", url: "https://www.youtube.com/watch?v=tTip4UnAZfA" },
    { type: "code",  name: "code",  url: "https://github.com/jdupuy/CauchyPolygons" },
]
---

<p>
<strong>Abstract.</strong>

Consider a uniform variate on the unit upper-half sphere of dimension d. It is known that the straight-line projection through the center of the unit sphere onto the plane above it distributes this variate according to a d-dimensional projective-Cauchy distribution. In this work, we leverage the geometry of this construction in dimension d=2 to derive new properties for the bivariate projective-Cauchy distribution. Specifically, we reveal via geometric intuitions that integrating and simulating a bivariate projective-Cauchy distribution within an arbitrary domain translates into respectively measuring and sampling the solid angle subtended by the geometry of this domain as seen from the origin of the unit sphere. To make this result practical for, e.g., generating truncated variants of the bivariate projective-Cauchy distribution, we extend it in two respects. First, we provide a generalization to Cauchy distributions parameterized by location-scale-correlation coefficients. Second, we provide a specialization to polygonal-domains, which leads to closed-form expressions. We provide a complete MATLAB implementation for the case of triangular domains, and briefly discuss the case of elliptical domains and how to further extend our results to bivariate Student distributions.

</p>

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/tTip4UnAZfA" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>
