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
# include_url: by_example_texture_demo.html
---

Use this tool to synthesize a new texture of arbitrary size from a provided example stochastic texture, by splatting random tiles of the input to the output using <a href="https://eheitzresearch.wordpress.com/722-2/">histogram-preserving blending</a>. It works on all random-phase inputs, as well as on many non-random-phase inputs which are stochastic and non-periodic, typically natural textures such as moss, granite, sand, bark, etc.
<br />
<ul>
  <li><a href="https://hal.inria.fr/hal-01824773/document">High-Performance By-Example Noise using a Histogram-Preserving Blending Operator</a>, HPG 2018</li>
  <li><a href="https://drive.google.com/file/d/1QecekuuyWgw68HU9tg6ENfrCTCVIjm6l/view">Procedural Stochastic Textures by Tiling and Blending</a>, GPU Zen 2</li>
</ul>


<!-- Demo code -->
<br />
<div style="color:darkred; width:80%; padding-left:10%; padding-right:10%;">
Disclaimer: this is a CPU implementation that runs in javascript.
The GPU implementation presented in the paper is orders of magnitude faster.
</div>
<br />

<div class="column">
  <div class="col-sm-4">
    1. Import example texture:
    <input type="file" id="files" name="files[]" multiple />
    <output id="list"></output>
    <br />
    <br />

    2. Is your example a tileable texture ?
    <br />
    <i>Tileable textures allow more varied random tile sampling.</i>
    <br />
    <div id="radioBtntileableExample"></div>

    <br />

    3. Select tile size in input image (0-50%):
    <br />
    <i>Larger tile size allows preserving lower frequencies in the example.
      <br />
      The blue tiles drawn below illustrate a possible random sampling of the input with the chosen tile
      size.</i>
    <br />
    <div class="slideTileSize">
      <input type="range" min="0" max="50" value="25" class="slider" id="tileSizeSlider">
      <input type="number" min="0" max="50" value="25" id="tileSizeField" />
    </div>

    <br />

    <canvas id="inputCanvas" width="256" height="256" style="border: dashed 1px #444;">
      Texte pour les navigateurs ne supportant pas le HTML5 Canvas.
    </canvas>

    <br />
    <br />

    4. Select output image resolution (width, height):
    <div id="imageWidth">
      <input type="number" min="32" value="512" id="inputImageWidth" />
      <input type="number" min="32" value="512" id="inputImageHeight" />
    </div>

    <br />

    5. Random seed:
    <div id="seedControls">
      <input type="number" value="4256" min="0" max="4294967296" id="inputSeed" />
      <button onclick="changeSeed()">Change</button>
    </div>

  </div>
</div>

<br />

<div id="outputImage">
  6. Generate output:
  <div id="controls">
    <button onclick="resynthesis()">Compute</button>
    <button onclick="changeSeedAndResynthesis()">Change Seed & Compute</button>
  </div>

  <br />

  7. Output:
  <div id="outputControls">
    <button onclick="saveResult()" id="downloadButton">Download Result</button>
    <button onclick="switchDisplayMode()" id="switchDisplayButton">Enable 2x2 Tiling Preview</button>
  </div>
  <i>The output display might be rescaled. Use the button above to download.</i>
  <br />

  <canvas id="outputCanvas" width="0" height="0" style="border: border: dashed 1px #444;">
    Texte pour les navigateurs ne supportant pas le HTML5 Canvas.
  </canvas>

</div>

<br />
<br />



<script type="text/javascript">

  /****************** UI ************************/
  /**********************************************/
  /**********************************************/
  /**********************************************/
  /**********************************************/
  // canvas input
  var c = document.getElementById("inputCanvas");
  var ctx = c.getContext("2d");

  // image data
  var A;
  var imageInput = { dataR: [], dataG: [], dataB: [], width: 0, height: 0 };

  // output data
  var cOutput = document.getElementById("outputCanvas");
  var ctxOutput = cOutput.getContext("2d");
  var output;
  var outputDataURL;

  // display parameters
  var displayTiled = false;

  initInterface();

  // Init UI
  function initInterface() {
    // remove radio buttons
    var rTileable = document.getElementsByName("tileableExample");
    for (var i = 0; i < rTileable.length; ++i) {
      rTileable[i].parentElement.removeChild(rTileable[i]);
    }

    // is example tileable
    document.getElementById("radioBtntileableExample").innerHTML = 'Yes:<input type="radio" value="true" name="tileableExample"> <br/> No:<input type="radio" value="false" name="tileableExample"> <br/>';
    rTileable = document.getElementsByName("tileableExample");
    rTileable[1].checked = true;
    rTileable[0].onchange = drawInputCanvas;
    rTileable[1].onchange = drawInputCanvas;

    // tile size
    var slider = document.getElementById("tileSizeSlider");
    slider.oninput = setTileSizeFromSlider
    var field = document.getElementById("tileSizeField");
    field.oninput = setTileSizeFromField
    drawInputCanvas();
  }

  // manage UI updates
  function drawInputCanvas() {
    if (typeof A === 'undefined' || A.width <= 0)
      return;

    // Change canvas size for adjusted display
    var inputScale = Math.min(window.innerWidth * 0.4, A.width) / A.width;
    var outputScale = 9999;
    if (cOutput.width > 0)
      var outputScale = Math.min(window.innerWidth * 0.4, output.width) / output.width;
    c.width = Math.min(inputScale, outputScale) * A.width;
    c.height = c.width * (A.height / A.width);
    ctx.drawImage(A, 0, 0, c.width, c.height);

    var tileSize = getTileSize();
    var resizer = c.width / A.width;
    tileSize *= resizer;

    // Display random tile sampling
    ctx.beginPath();
    ctx.strokeStyle = "blue";
    ctx.lineWidth = "2";
    var isTileable = getTileableExample();
    var sampleCount = Math.min(64, Math.min(imageInput.width, imageInput.height) * resizer / tileSize * 2);
    var today = new Date();
    setSeed(today.getHours() * today.getMinutes() * today.getSeconds() + today.getMilliseconds())
    for (var i = 0; i < sampleCount; i++) {
      // Display main tile
      var offset_i = Math.floor((A.width * resizer - (isTileable ? 0 : tileSize)) * randXorshiftFloat());
      var offset_j = Math.floor((A.height * resizer - (isTileable ? 0 : tileSize)) * randXorshiftFloat());
      ctx.rect(offset_i, offset_j, tileSize, tileSize);
      ctx.stroke();

      // Display overflow of tile if tileable sampling enabled
      if (isTileable) {
        if (offset_i + tileSize > c.width) {
          ctx.rect(offset_i - c.width, offset_j, tileSize, tileSize);
          ctx.stroke();
        }
        if (offset_j + tileSize > c.height) {
          ctx.rect(offset_i, offset_j - c.height, tileSize, tileSize);
          ctx.stroke();
        }
        if (offset_i + tileSize > c.width && offset_j + tileSize > c.height) {
          ctx.rect(offset_i - c.width, offset_j - c.height, tileSize, tileSize);
          ctx.stroke();
        }
      }
    }
  };

  // is example texture tileable
  function getTileableExample() {
    var r = document.getElementsByName("tileableExample");
    if (r[0].checked)
      return true
    else
      return false
  }

  // Border size control
  function setTileSizeFromSlider() {
    var field = document.getElementById("tileSizeField");
    var slider = document.getElementById("tileSizeSlider");
    field.value = slider.value;
    drawInputCanvas();
  }

  // Border size control
  function setTileSizeFromField() {
    var field = document.getElementById("tileSizeField");
    var slider = document.getElementById("tileSizeSlider");
    slider.value = field.value;
    drawInputCanvas();
  }

  // get size of tiles from UI
  function getTileSize() {
    var slider = document.getElementById("tileSizeSlider");
    pos = slider.value / 100.0
    return Math.max(2 * Math.floor(pos * Math.min(imageInput.width, imageInput.height) / 2.0), 2)
  }

  // get desired output width
  function getTargetWidth() {
    return document.getElementById("inputImageWidth").value;
  }

  // get desired output height
  function getTargetHeight() {
    return document.getElementById("inputImageHeight").value;
  }

  // mage file input
  document.getElementById('files').addEventListener('change', handleFileSelect, false);
  function handleFileSelect(evt) {
    var files = evt.target.files; // FileList object

    // Loop through the FileList and render image files as thumbnails.
    for (var i = 0, f; f = files[i]; i++) {
      // Only process image files.
      if (!f.type.match('image.*')) {
        continue;
      }

      var reader = new FileReader();

      reader.onload =
        (function (theFile) {
          return function (e) {
            A = new Image();
            A.src = e.target.result;

            A.onload =
              function () {
                // display image
                c.width = A.width;
                c.height = A.height;
                ctx.drawImage(A, 0, 0)

                // copy image data
                var copie_img_chat = ctx.getImageData(0, 0, c.width, c.height);
                var data = copie_img_chat.data;
                imageInput.width = c.width;
                imageInput.height = c.height;
                imageInput.dataR = [];
                imageInput.dataG = [];
                imageInput.dataB = [];
                for (var j = 0; j < c.height; ++j) {
                  imageInput.dataR[j] = [];
                  imageInput.dataG[j] = [];
                  imageInput.dataB[j] = [];

                  for (var i = 0; i < c.width; ++i) {
                    imageInput.dataR[j][i] = data[4 * (i + j * c.width) + 0];
                    imageInput.dataG[j][i] = data[4 * (i + j * c.width) + 1];
                    imageInput.dataB[j][i] = data[4 * (i + j * c.width) + 2];
                  }
                }

                clearOutput();
                initInterface();
              };
          };
        })(f);
      reader.readAsDataURL(f);
    }
  }

  function switchDisplayMode() {
    if (displayTiled == true) {
      displayOutput();
      var newButtons = '<button onclick="saveResult()" id="downloadButton">Download Result</button><button onclick="switchDisplayMode()" id="switchDisplayButton">Enable 2x2 Tiling Preview</button>';
      document.getElementById("outputControls").innerHTML = newButtons;
      displayTiled = false;
    }
    else {
      displayTiledOutput();
      var newButtons = '<button onclick="saveResult()" id="downloadButton">Download Result</button><button onclick="switchDisplayMode()" id="switchDisplayButton">Disable 2x2 Tiling Preview</button>';
      document.getElementById("outputControls").innerHTML = newButtons;
      displayTiled = true;
    }
  }

  // Display output in resized canvas
  function displayOutput() {
    var imageOutput = new Image();
    imageOutput.src = outputDataURL;

    // Draw to resized output canvas when finished loading
    imageOutput.onload = function () {
      // Change canvas size for adjusted display
      var inputScale = Math.min(window.innerWidth * 0.4, A.width) / A.width;
      var outputScale = Math.min(window.innerWidth * 0.4, imageOutput.width) / imageOutput.width;
      cOutput.width = Math.min(inputScale, outputScale) * imageOutput.width;
      cOutput.height = cOutput.width * (imageOutput.height / imageOutput.width);
      // Draw resized output image
      ctxOutput.drawImage(imageOutput, 0, 0, cOutput.width, cOutput.height);
      drawInputCanvas();
    };
    displayTiled = false;
  }

  // Display tiled output in resized canvas
  function displayTiledOutput() {
    var imageOutput = new Image();
    imageOutput.src = outputDataURL;
    // Draw to resized output canvas when finished loading
    imageOutput.onload = function () {
      // Change canvas size for adjusted display
      var inputScale = Math.min(window.innerWidth * 0.4, A.width) / A.width;
      var outputScale = Math.min(window.innerWidth * 0.4, imageOutput.width) / imageOutput.width;
      cOutput.width = Math.min(inputScale, outputScale) * imageOutput.width * 2;
      cOutput.height = cOutput.width * (imageOutput.height / imageOutput.width);
      // Draw resized output image in 2*2 tiling
      ctxOutput.drawImage(imageOutput, 0, 0, cOutput.width / 2, cOutput.height / 2);
      ctxOutput.drawImage(imageOutput, cOutput.width / 2, 0, cOutput.width / 2, cOutput.height / 2);
      ctxOutput.drawImage(imageOutput, cOutput.width / 2, cOutput.height / 2, cOutput.width / 2, cOutput.height / 2);
      ctxOutput.drawImage(imageOutput, 0, cOutput.height / 2, cOutput.width / 2, cOutput.height / 2);
      drawInputCanvas();
    };
    displayTiled = true;
  }

  // Download output
  function saveResult() {
    // Create download action
    var a = document.createElement('a');
    a.href = outputDataURL;
    a.download = 'image.png';
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  }

  // Clear Output
  function clearOutput() {
    cOutput.width = 0;
    cOutput.height = 0;
    output = null
    outputDataURL = null
  }


  /****************** ALGORITHM *****************/
  /**********************************************/
  /**********************************************/
  /**********************************************/
  /**********************************************/
  var rngState = 0;

  function wangHash(seed) {
    seed = (seed ^ 61) ^ (seed >> 16);
    seed *= 9;
    seed = seed ^ (seed >> 4);
    seed *= 0x27d4eb2d;
    seed = seed ^ (seed >> 15);
    return seed;
  }

  function randXorshift() {
    // Xorshift algorithm from George Marsaglia's paper
    rngState ^= (rngState << 13);
    rngState ^= (rngState >> 17);
    rngState ^= (rngState << 5);
    rngState = customModulo(rngState, 4294967296)
  }

  function randXorshiftFloat() {
    randXorshift();
    var res = rngState * (1.0 / 4294967296.0);
    return res;
  }

  function setSeed(i) {
    rngState = wangHash(i);
  }

  function changeSeed() {
    setSeed(getInputSeed())
    document.getElementById("inputSeed").value = Math.floor(randXorshiftFloat() * 4294967296);
  }

  function getInputSeed() {
    return document.getElementById("inputSeed").value;
  }

  function customModulo(x, n) {
    var r = x % n;
    if (r < 0) {
      r += n;
    }
    return r;
  }

  function changeSeedAndResynthesis() {
    changeSeed();
    resynthesis();
  }

  // MAIN GENERATION FUNCTION
  function resynthesis() {
    // Set random seed
    setSeed(getInputSeed())

    // get algorithm parameters from UI
    var isTileable = getTileableExample();
    var desiredRadius = getTileSize() / 2;
    var targetWidth = getTargetWidth();
    var targetHeight = getTargetHeight();
    var inputWidth = A.width;
    var inputHeight = A.height;

    // Compute adjusted optimal tile size for selected border and output sizes
    var tileCountWidth = Math.floor(targetWidth / desiredRadius);
    var tileRadiusWidth = desiredRadius;
    var restWidth = targetWidth - tileRadiusWidth * tileCountWidth;
    tileRadiusWidth += Math.floor(restWidth / tileCountWidth);
    restWidth = targetWidth - tileRadiusWidth * tileCountWidth;

    var tileCountHeight = Math.floor(targetHeight / desiredRadius);
    var tileRadiusHeight = desiredRadius;
    var restHeight = targetHeight - tileRadiusHeight * tileCountHeight;
    tileRadiusHeight += Math.floor(restHeight / tileCountHeight);
    restHeight = targetHeight - tileRadiusHeight * tileCountHeight;

    var tileWidth = tileRadiusWidth * 2;
    var tileHeight = tileRadiusHeight * 2;

    // allocate output image
    output = { dataR: [], dataG: [], dataB: [], width: targetWidth, height: targetHeight };
    for (var j = 0; j < output.height; ++j) {
      output.dataR[j] = [];
      output.dataG[j] = [];
      output.dataB[j] = [];
      for (var i = 0; i < output.width; ++i) {
        output.dataR[j][i] = 0;
        output.dataG[j][i] = 0;
        output.dataB[j][i] = 0;
      }
    }

    // make input image have a Gaussian histogram
    eigenVectors = [];
    for (var i = 0; i < 3; i++)
      eigenVectors[i] = [0, 0, 0];
    var imageInputGaussian = makeHistoGaussianEigen(imageInput, eigenVectors);

    // loop over the tiles and splat them in the output image
    for (var j_tile = 0; j_tile < tileCountHeight; ++j_tile) {
      for (var i_tile = 0; i_tile < tileCountWidth; ++i_tile) {
        // For the last restWidth tiles on top border, and the last restHeight tiles on left border,
        // extend the center of the tile to a 1-wide zone where no blending occurs between tiles to account
        // for the missing pixels when image_dimensions / desired_border_size has a remainder
        var tileCenterWidth = 0;
        var tileCenterHeight = 0;
        var cumulativeOffsetWidth = 0;
        var cumulativeOffsetHeight = 0;
        if (i_tile > tileCountWidth - 2 - restWidth) {
          tileCenterWidth = 1;
          cumulativeOffsetWidth = (i_tile - 1) - (tileCountWidth - 2 - restWidth)
        }
        else if (j_tile > tileCountHeight - 2 - restHeight) {
          tileCenterHeight = 1;
          cumulativeOffsetHeight = (j_tile - 1) - (tileCountHeight - 2 - restHeight)
        }

        // random offset of the tile
        var offset_i = Math.floor((imageInput.width - (isTileable ? 0 : (tileWidth + tileCenterWidth))) * randXorshiftFloat());
        var offset_j = Math.floor((imageInput.height - (isTileable ? 0 : (tileHeight + tileCenterHeight))) * randXorshiftFloat());

        // for each pixel of the tile
        for (var j = 0; j < tileHeight + tileCenterHeight; ++j) {
          for (var i = 0; i < tileWidth + tileCenterWidth; ++i) {
            // compute the weight of this pixel of the tile
            // (linear interpolation + variance correction)
            var w = 0.0;

            // Special case for center extension of the tile
            if (i >= tileWidth / 2 && i < tileWidth / 2 + tileCenterWidth
              && j >= tileHeight / 2 && j < tileHeight / 2 + tileCenterHeight) {
              w = 1.0;
            }
            // Normal case, bilinear blend of this tile and neighbouring tiles
            else {
              // If it exists, cancel out tile center extension in blend computation
              var temp_j = j;
              if (j >= tileHeight / 2 + tileCenterHeight)
                temp_j = j - tileCenterHeight;
              var temp_i = i;
              if (i >= tileWidth / 2 + tileCenterWidth)
                temp_i = i - tileCenterWidth;

              // Variance-preserving bilinear blend weights
              var lambda_x = 1.0 - Math.floor(Math.abs(temp_i - 0.5 * (tileWidth - 1))) / (tileWidth / 2 - 1);
              var lambda_y = 1.0 - Math.floor(Math.abs(temp_j - 0.5 * (tileHeight - 1))) / (tileHeight / 2 - 1);
              var w00 = (1.0 - lambda_x) * (1.0 - lambda_y);
              var w10 = (lambda_x) * (1.0 - lambda_y);
              var w01 = (1.0 - lambda_x) * (lambda_y);
              var w11 = (lambda_x) * (lambda_y);
              w = lambda_x * lambda_y / Math.sqrt(w00 * w00 + w10 * w10 + w01 * w01 + w11 * w11);
            }

            // Add weighted tile contribution to output pixel
            var index_i_output = customModulo(i + i_tile * tileWidth / 2 + cumulativeOffsetWidth, targetWidth);
            var index_j_output = customModulo(j + j_tile * tileHeight / 2 + cumulativeOffsetHeight, targetHeight);
            var index_i_input = (i + offset_i) % inputWidth;
            var index_j_input = (j + offset_j) % inputHeight;
            output.dataR[index_j_output][index_i_output] +=
              w * imageInputGaussian.dataR[index_j_input][index_i_input];
            output.dataG[index_j_output][index_i_output] +=
              w * imageInputGaussian.dataG[index_j_input][index_i_input];
            output.dataB[index_j_output][index_i_output] +=
              w * imageInputGaussian.dataB[index_j_input][index_i_input];
          }
        }
      }
    }

    // make output image have same histogram as input
    output = unmakeHistoGaussianEigen(output, imageInput, eigenVectors);

    // Prepare data URL for display/download
    outputDataURL = dataToDataURL(output)

    // display output in canvas
    if (displayTiled == false)
      displayOutput();
    else
      displayTiledOutput();
  }

  function dataToDataURL(input) {
    var imageData = new ImageData(input.width, input.height);
    var data = imageData.data;
    for (var j = 0; j < input.height; ++j)
      for (var i = 0; i < input.width; ++i) {
        data[4 * (i + j * input.width) + 0] = input.dataR[j][i];
        data[4 * (i + j * input.width) + 1] = input.dataG[j][i];
        data[4 * (i + j * input.width) + 2] = input.dataB[j][i];
        data[4 * (i + j * input.width) + 3] = 255;
      }
    var cOutput2 = document.createElement('canvas');
    var ctxOutput2 = cOutput2.getContext("2d");
    cOutput2.width = input.width;
    cOutput2.height = input.height;
    ctxOutput2.putImageData(imageData, 0, 0);
    var dataURL = cOutput2.toDataURL('image/png');
    return dataURL;
  }

  // input: image with arbitrary histogram
  // returns transformed input with Gaussian histogram in eigen space
  function makeHistoGaussianEigen(input, eigenVectors) {
    eigenOffset = [0, 0, 0];
    getImageRGBEigenVectors(input, eigenVectors)

    // sort pixels
    Rsorted = [];
    Gsorted = [];
    Bsorted = [];
    for (var j = 0; j < input.height; ++j) {
      for (var i = 0; i < input.width; ++i) {
        var pixelR = { index_i: i, index_j: j, value: input.dataR[j][i] };
        var pixelG = { index_i: i, index_j: j, value: input.dataG[j][i] };
        var pixelB = { index_i: i, index_j: j, value: input.dataB[j][i] };

        // Project onto eigen axes
        var p = [pixelR.value, pixelG.value, pixelB.value];
        pixelR.value = dot(p, eigenVectors[0]);
        pixelG.value = dot(p, eigenVectors[1]);
        pixelB.value = dot(p, eigenVectors[2]);

        Rsorted[i + j * input.width] = pixelR;
        Gsorted[i + j * input.width] = pixelG;
        Bsorted[i + j * input.width] = pixelB;
      }
    }
    Rsorted.sort(function (a, b) { return a.value - b.value; });
    Gsorted.sort(function (a, b) { return a.value - b.value; });
    Bsorted.sort(function (a, b) { return a.value - b.value; });

    // allocate output
    var output = { dataR: [], dataG: [], dataB: [], width: input.width, height: input.height };
    for (var j = 0; j < input.height; ++j) {
      output.dataR[j] = [];
      output.dataG[j] = [];
      output.dataB[j] = [];
      for (var i = 0; i < input.width; ++i) {
        output.dataR[j][i] = 0;
        output.dataG[j][i] = 0;
        output.dataB[j][i] = 0;
      }
    }

    // maps uniform to Gaussian
    for (var index = 0; index < input.width * input.height; ++index) {
      // maps index to uniform number
      var U = (index + 0.5) / (input.width * input.height);
      // maps uniform to Gaussian
      var G = Math.sqrt(2.0) * erfinv(2 * U - 1.0);
      // store
      output.dataR[Rsorted[index].index_j][Rsorted[index].index_i] = G;
      output.dataG[Gsorted[index].index_j][Gsorted[index].index_i] = G;
      output.dataB[Bsorted[index].index_j][Bsorted[index].index_i] = G;
    }

    return output;
  }

  // input: image with Gaussian histogram
  // target: image with target histogram
  // returns transformed input with target histogram
  function unmakeHistoGaussianEigen(input, target, eigenVectors) {
    // sort target values
    Rsorted = [];
    Gsorted = [];
    Bsorted = [];
    for (var j = 0; j < target.height; ++j)
      for (var i = 0; i < target.width; ++i) {
        var p = [target.dataR[j][i], target.dataG[j][i], target.dataB[j][i]];
        Rsorted[i + j * target.width] = dot(p, eigenVectors[0]);
        Gsorted[i + j * target.width] = dot(p, eigenVectors[1]);
        Bsorted[i + j * target.width] = dot(p, eigenVectors[2]);
      }
    Rsorted.sort(function (a, b) { return a - b; });
    Gsorted.sort(function (a, b) { return a - b; });
    Bsorted.sort(function (a, b) { return a - b; });

    // allocate output
    var output = { dataR: [], dataG: [], dataB: [], width: input.width, height: input.height };
    for (var j = 0; j < input.height; ++j) {
      output.dataR[j] = [];
      output.dataG[j] = [];
      output.dataB[j] = [];
      for (var i = 0; i < input.width; ++i) {
        output.dataR[j][i] = 0;
        output.dataG[j][i] = 0;
        output.dataB[j][i] = 0;
      }
    }

    // maps Gaussian values to target values
    for (var j = 0; j < input.height; ++j)
      for (var i = 0; i < input.width; ++i) {
        // red channel
        var Gr = input.dataR[j][i];
        var Ur = 0.5 + 0.5 * erf(Gr / Math.sqrt(2.0));
        var indexR = Math.floor(Ur * target.width * target.height);
        output.dataR[j][i] = Rsorted[indexR];

        // green channel
        var Gg = input.dataG[j][i];
        var Ug = 0.5 + 0.5 * erf(Gg / Math.sqrt(2.0));
        var indexG = Math.floor(Ug * target.width * target.height);
        output.dataG[j][i] = Gsorted[indexG];

        // blue channel
        var Gb = input.dataB[j][i];
        var Ub = 0.5 + 0.5 * erf(Gb / Math.sqrt(2.0));
        var indexB = Math.floor(Ub * target.width * target.height);
        output.dataB[j][i] = Bsorted[indexB];

        var rgb =
          addVector3(
            addVector3(
              mulVector3(eigenVectors[0], output.dataR[j][i]),
              mulVector3(eigenVectors[1], output.dataG[j][i])),
            mulVector3(eigenVectors[2], output.dataB[j][i]));

        output.dataR[j][i] = rgb[0];
        output.dataG[j][i] = rgb[1];
        output.dataB[j][i] = rgb[2];
      }

    return output;
  }


  function getImageRGBEigenVectors(input, eigenVectors) {
    var expectedRGB = [0, 0, 0];
    var expectedRGBtimesR = [0, 0, 0];
    var expectedRGBtimesG = [0, 0, 0];
    var expectedRGBtimesB = [0, 0, 0];
    for (var j = 0; j < input.height; ++j) {
      for (var i = 0; i < input.width; ++i) {
        expectedRGB[0] += input.dataR[j][i];
        expectedRGB[1] += input.dataG[j][i];
        expectedRGB[2] += input.dataB[j][i];

        expectedRGBtimesR[0] += input.dataR[j][i] * input.dataR[j][i];
        expectedRGBtimesR[1] += input.dataG[j][i] * input.dataR[j][i];
        expectedRGBtimesR[2] += input.dataB[j][i] * input.dataR[j][i];

        expectedRGBtimesG[0] += input.dataR[j][i] * input.dataG[j][i];
        expectedRGBtimesG[1] += input.dataG[j][i] * input.dataG[j][i];
        expectedRGBtimesG[2] += input.dataB[j][i] * input.dataG[j][i];

        expectedRGBtimesB[0] += input.dataR[j][i] * input.dataB[j][i];
        expectedRGBtimesB[1] += input.dataG[j][i] * input.dataB[j][i];
        expectedRGBtimesB[2] += input.dataB[j][i] * input.dataB[j][i];
      }
    }
    for (var i = 0; i < 3; i++) {
      expectedRGB[i] /= input.width * input.height;
      expectedRGBtimesR[i] /= input.width * input.height;
      expectedRGBtimesG[i] /= input.width * input.height;
      expectedRGBtimesB[i] /= input.width * input.height;
    }

    // Covariance matrix
    covarMat = [];
    for (var i = 0; i < 3; i++)
      covarMat[i] = [0, 0, 0];

    covarMat[0][0] = expectedRGBtimesR[0] - expectedRGB[0] * expectedRGB[0];
    covarMat[0][1] = expectedRGBtimesR[1] - expectedRGB[0] * expectedRGB[1];
    covarMat[0][2] = expectedRGBtimesR[2] - expectedRGB[0] * expectedRGB[2];

    covarMat[1][0] = expectedRGBtimesG[0] - expectedRGB[1] * expectedRGB[0];
    covarMat[1][1] = expectedRGBtimesG[1] - expectedRGB[1] * expectedRGB[1];
    covarMat[1][2] = expectedRGBtimesG[2] - expectedRGB[1] * expectedRGB[2];

    covarMat[2][0] = expectedRGBtimesB[0] - expectedRGB[2] * expectedRGB[0];
    covarMat[2][1] = expectedRGBtimesB[1] - expectedRGB[2] * expectedRGB[1];
    covarMat[2][2] = expectedRGBtimesB[2] - expectedRGB[2] * expectedRGB[2];

    // Find eigen values and vectors
    eigenValues = [0, 0, 0];
    computeEigenValuesAndVectors(covarMat, eigenVectors, eigenValues);
    var x = 0;
  }

  function computeEigenValuesAndVectors(A, Q, w) {
    var n = 3;
    var sd, so;                  // Sums of diagonal resp. off-diagonal elements
    var s, c, t;                 // sin(phi), cos(phi), tan(phi) and temporary storage
    var g, h, z, theta;          // More temporary storage
    var thresh;

    // Initialize Q to the identitity matrix
    for (var i = 0; i < n; i++) {
      Q[i][i] = 1.0;
      for (var j = 0; j < i; j++)
        Q[i][j] = Q[j][i] = 0.0;
    }

    // Initialize w to diag(A)
    for (var i = 0; i < n; i++)
      w[i] = A[i][i];

    // Calculate SQR(tr(A))
    sd = 0.0;
    for (var i = 0; i < n; i++)
      sd += Math.abs(w[i]);
    sd = sd * sd;

    // Main iteration loop
    for (var nIter = 0; nIter < 50; nIter++) {
      // Test for convergence
      so = 0.0;
      for (var p = 0; p < n; p++)
        for (var q = p + 1; q < n; q++)
          so += Math.abs(A[p][q]);
      if (so == 0.0)
        return 0;

      if (nIter < 4)
        thresh = 0.2 * so / (n * n);
      else
        thresh = 0.0;

      // Do sweep
      for (var p = 0; p < n; p++) {
        for (var q = p + 1; q < n; q++) {
          g = 100.0 * Math.abs(A[p][q]);
          if (nIter > 4 && Math.abs(w[p]) + g == Math.abs(w[p])
            && Math.abs(w[q]) + g == Math.abs(w[q])) {
            A[p][q] = 0.0;
          }
          else if (Math.abs(A[p][q]) > thresh) {
            // Calculate Jacobi transformation
            h = w[q] - w[p];
            if (Math.abs(h) + g == Math.abs(h)) {
              t = A[p][q] / h;
            }
            else {
              theta = 0.5 * h / A[p][q];
              if (theta < 0.0)
                t = -1.0 / (Math.sqrt(1.0 + (theta * theta)) - theta);
              else
                t = 1.0 / (Math.sqrt(1.0 + (theta * theta)) + theta);
            }
            c = 1.0 / Math.sqrt(1.0 + (t * t));
            s = t * c;
            z = t * A[p][q];

            // Apply Jacobi transformation
            A[p][q] = 0.0;
            w[p] -= z;
            w[q] += z;
            for (var r = 0; r < p; r++) {
              t = A[r][p];
              A[r][p] = c * t - s * A[r][q];
              A[r][q] = s * t + c * A[r][q];
            }
            for (var r = p + 1; r < q; r++) {
              t = A[p][r];
              A[p][r] = c * t - s * A[r][q];
              A[r][q] = s * t + c * A[r][q];
            }
            for (var r = q + 1; r < n; r++) {
              t = A[p][r];
              A[p][r] = c * t - s * A[q][r];
              A[q][r] = s * t + c * A[q][r];
            }

            // Update eigenvectors
            for (var r = 0; r < n; r++) {
              t = Q[p][r];
              Q[p][r] = c * t - s * Q[q][r];
              Q[q][r] = s * t + c * Q[q][r];
            }
          }
        }
      }
    }

    return -1;
  }

  function erf(x) {
    var a1 = 0.254829592;
    var a2 = -0.284496736;
    var a3 = 1.421413741;
    var a4 = -1.453152027;
    var a5 = 1.061405429;
    var p = 0.3275911;

    var sign = 1;
    if (x < 0)
      sign = -1;
    x = Math.abs(x);

    var t = 1.0 / (1.0 + p * x);
    var y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);

    return sign * y;
  }

  function erfinv(x) {
    var w, p;
    w = - Math.log((1.0 - x) * (1.0 + x));
    if (w < 5.000000) {
      w = w - 2.500000;
      p = 2.81022636e-08;
      p = 3.43273939e-07 + p * w;
      p = -3.5233877e-06 + p * w;
      p = -4.39150654e-06 + p * w;
      p = 0.00021858087 + p * w;
      p = -0.00125372503 + p * w;
      p = -0.00417768164 + p * w;
      p = 0.246640727 + p * w;
      p = 1.50140941 + p * w;
    }
    else {
      w = Math.sqrt(w) - 3.000000;
      p = -0.000200214257;
      p = 0.000100950558 + p * w;
      p = 0.00134934322 + p * w;
      p = -0.00367342844 + p * w;
      p = 0.00573950773 + p * w;
      p = -0.0076224613 + p * w;
      p = 0.00943887047 + p * w;
      p = 1.00167406 + p * w;
      p = 2.83297682 + p * w;
    }
    return p * x;
  }

  function dot(a, b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
  }

  function mulVector3(a, b) {
    return [a[0] * b, a[1] * b, a[2] * b];
  }

  function addVector3(a, b) {
    return [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
  }

</script>
