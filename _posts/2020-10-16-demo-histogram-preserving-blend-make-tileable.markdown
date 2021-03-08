---
layout: demo
date:   2020-10-16
title:  "Make your texture tileable with histogram-preserving blending"
authors: [
            { name: "Thomas Deliot"},
            { name: "Eric Heitz"},
            { name: "Fabrice Neyret", affiliation: "CNRS/Inria", url: "http://evasion.imag.fr/Membres/Fabrice.Neyret/"}
         ]
categories: demo
thumbnail: "/images/thumbnails/demo_texture_synthesis_2.png"
include_url: by_example_texture_make_tileable.html
---

Use this tool to turn an existing, non-tileable stochastic texture into a tileable texture, by manipulating its edges using <a href="https://eheitzresearch.wordpress.com/722-2/">histogram-preserving blending</a>. It works on all random-phase inputs, as well as on many non-random-phase inputs which are stochastic and non-periodic, typically natural textures such as moss, granite, sand, bark, etc.
<br />
<ul>
  <li><a href="https://hal.inria.fr/hal-01824773/document">High-Performance By-Example Noise using a Histogram-Preserving Blending Operator</a>, HPG 2018</li>
  <li><a href="https://drive.google.com/file/d/1QecekuuyWgw68HU9tg6ENfrCTCVIjm6l/view">Procedural Stochastic Textures by Tiling and Blending</a>, GPU Zen 2</li>
</ul>

<br />
<div style="color:darkred; width:80%; padding-left:10%; padding-right:10%;">
Disclaimer: this is a CPU implementation that runs in javascript.
The GPU implementation presented in the paper is orders of magnitude faster.
</div>
<br />

<div id="inputImage">

  1. Import example texture:
  <input type="file" id="files" name="files[]" multiple />
  <output id="list"></output>
  <br />
  <br />
  <canvas id="inputCanvas" width="256" height="256" style="border: dashed 1px #444;">
    Texte pour les navigateurs ne supportant pas le HTML5 Canvas.
  </canvas>
  <br />

</div>

<br />

<div class="column">
  <div class="col-sm-4">
    2. Adjust blending border width (0-100%):
    <div class="slideBorderSize">
      <input type="range" min="0" max="100" value="33" class="slider" id="borderSizeSlider">
      <input type="number" min="0" max="100" value="33" id="borderSizeField" />
    </div>

    <br />

    3. Random seed:
    <div id="seedControls">
      <input type="number" value="4256" min="0" max="4294967296" id="inputSeed" />
      <button onclick="changeSeed()">Change</button>
    </div>
  </div>
</div>

<br />

<div id="outputImage">
  4. Generate output:
  <div id="controls">
    <button onclick="resynthesis()">Compute</button>
    <button onclick="changeSeedAndResynthesis()">Change Seed & Compute</button>
  </div>

  <br />

  5. Output:
  <div id="outputControls">
    <button onclick="saveResult()" id="downloadButton">Download Result</button>
    <button onclick="switchTilingMode()" id="switchTilingButton">Show 2x2 Tiling Preview</button>
    <button onclick="switchOutputSource()" id="switchOutputSourceButton">Show Original</button>
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
  var exampleStored;
  var example;
  var imageInput = { dataR: [], dataG: [], dataB: [], width: 0, height: 0 };
  var gradientRemovalApplied = false;

  // output data
  var cOutput = document.getElementById("outputCanvas");
  var ctxOutput = cOutput.getContext("2d");
  var output;
  var outputDataURL;

  // display parameters
  var displayTiled = false;
  var displayOriginal = false;

  initInterface();

  // Init UI
  function initInterface(imageSize) {
    var slider = document.getElementById("borderSizeSlider");
    slider.oninput = setBorderSizeFromSlider
    var field = document.getElementById("borderSizeField");
    field.oninput = setBorderSizeFromField
    drawInputCanvas();
  }

  function rgb(r, g, b, a) {
    return 'rgb(' + [(r || 0), (g || 0), (b || 0), (a || 0)].join(',') + ')';
  }

  // manage UI updates
  function drawInputCanvas() {
    if (typeof example === 'undefined' || example.width <= 0)
      return;

    // Change canvas size for adjusted display
    var inputScale = Math.min(window.innerWidth * 0.4, example.width) / example.width;
    var outputScale = 9999;
    if (cOutput.width > 0)
      var outputScale = Math.min(window.innerWidth * 0.4, output.width) / output.width;
    c.width = Math.min(inputScale, outputScale) * example.width;
    c.height = c.width * (example.height / example.width);
    ctx.drawImage(example, 0, 0, c.width, c.height);

    var resizer = c.width / example.width;
    var borderSize = getBorderSize() * resizer;
    ctx.beginPath();
    ctx.strokeStyle = "blue";
    ctx.lineWidth = "3";
    ctx.rect(borderSize, borderSize, example.width * resizer - borderSize * 2, example.height * resizer - borderSize * 2);
    ctx.stroke();

    // Left blend gradient
    var gradient = ctx.createLinearGradient(0, 0, borderSize, 0);
    gradient.addColorStop(0, rgb(0, 0, 255, 1));
    gradient.addColorStop(1, rgb(0, 0, 255, 0));
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, example.width * resizer, example.height * resizer);

    // Top blend gradient
    gradient = ctx.createLinearGradient(0, 0, 0, borderSize);
    gradient.addColorStop(0, rgb(0, 0, 255, 1));
    gradient.addColorStop(1, rgb(0, 0, 255, 0));
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, example.width * resizer, example.height * resizer);

    // Right blend gradient
    gradient = ctx.createLinearGradient(example.width * resizer - borderSize, 0, example.width * resizer, 0);
    gradient.addColorStop(0, rgb(0, 0, 255, 0));
    gradient.addColorStop(1, rgb(0, 0, 255, 1));
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, example.width * resizer, example.height * resizer);

    // Bottom blend gradient
    gradient = ctx.createLinearGradient(0, example.height * resizer - borderSize, 0, example.height * resizer);
    gradient.addColorStop(0, rgb(0, 0, 255, 0));
    gradient.addColorStop(1, rgb(0, 0, 255, 1));
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, example.width * resizer, example.height * resizer);
  };

  // Border size control
  function setBorderSizeFromSlider() {
    var field = document.getElementById("borderSizeField");
    var slider = document.getElementById("borderSizeSlider");
    field.value = slider.value;
    drawInputCanvas();
  }

  // Border size control
  function setBorderSizeFromField() {
    var field = document.getElementById("borderSizeField");
    var slider = document.getElementById("borderSizeSlider");
    slider.value = field.value;
    drawInputCanvas();
  }

  // get size of tiles from UI
  function getBorderSize() {
    var slider = document.getElementById("borderSizeSlider");
    pos = slider.value / 100.0
    return Math.max(Math.floor(pos * Math.min(imageInput.width, imageInput.height) / 2.0), 2)
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
            example = new Image();
            example.src = e.target.result;

            example.onload =
              function () {
                exampleStored = example;

                // display image
                c.width = example.width;
                c.height = example.height;
                ctx.drawImage(example, 0, 0)

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

  function switchTilingMode() {
    if (displayTiled == true) {
      displayOutput();
      displayTiled = false;
    }
    else {
      displayTiledOutput();
      displayTiled = true;
    }
    resetControlsButtonText();
  }

  function switchOutputSource() {
    displayOriginal = !displayOriginal;
    if (displayTiled == false) {
      displayOutput();
    }
    else {
      displayTiledOutput();
    }
    resetControlsButtonText();
  }

  function resetControlsButtonText() {
    var newButtons = '';
    newButtons += '<button onclick="saveResult()" id="downloadButton">Download Result</button>   ';
    if (displayTiled == true)
      newButtons += '<button onclick="switchTilingMode()" id="switchTilingButton">Hide 2x2 Tiling Preview</button>   ';
    else
      newButtons += '<button onclick="switchTilingMode()" id="switchTilingButton">Show 2x2 Tiling Preview</button>   ';
    if (displayOriginal == true)
      newButtons += '<button onclick="switchOutputSource()" id="switchOutputSourceButton">Show Tileable</button>   ';
    else
      newButtons += '<button onclick="switchOutputSource()" id="switchOutputSourceButton">Show Original</button>   ';
    document.getElementById("outputControls").innerHTML = newButtons;
  }

  // Display output in resized canvas
  function displayOutput() {
    var imageOutput = new Image();
    imageOutput.src = displayOriginal == true ? example.src : outputDataURL;

    // Draw to resized output canvas when finished loading
    imageOutput.onload = function () {
      // Change canvas size for adjusted display
      var inputScale = Math.min(window.innerWidth * 0.4, example.width) / example.width;
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
    imageOutput.src = displayOriginal == true ? example.src : outputDataURL;
    // Draw to resized output canvas when finished loading
    imageOutput.onload = function () {
      // Change canvas size for adjusted display
      var inputScale = Math.min(window.innerWidth * 0.4, example.width) / example.width;
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

  function remapValue(value, low1, high1, low2, high2) {
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
  }

  function clamp(num, min, max) {
    return num <= min ? min : num >= max ? max : num;
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

  // algorithm main function
  function resynthesis() {
    // Set random seed
    setSeed(getInputSeed())

    // get algorithm parameters from UI
    var borderSize = getBorderSize();
    var targetWidth = imageInput.width;
    var targetHeight = imageInput.height;

    // Compute adjusted optimal tile size for selected border size
    var tileCountWidth = Math.floor(targetWidth / borderSize);
    var tileRadiusWidth = borderSize;
    var restWidth = targetWidth - tileRadiusWidth * tileCountWidth;
    tileRadiusWidth += Math.floor(restWidth / tileCountWidth);
    restWidth = targetWidth - tileRadiusWidth * tileCountWidth;

    var tileCountHeight = Math.floor(targetHeight / borderSize);
    var tileRadiusHeight = borderSize;
    var restHeight = targetHeight - tileRadiusHeight * tileCountHeight;
    tileRadiusHeight += Math.floor(restHeight / tileCountHeight);
    restHeight = targetHeight - tileRadiusHeight * tileCountHeight;

    var tileWidth = tileRadiusWidth * 2;
    var tileHeight = tileRadiusHeight * 2;

    // Allocate output image
    output = { dataR: [], dataG: [], dataB: [], totalWeight: [], width: targetWidth, height: targetHeight };
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

    // Remove edge gradients from input image
    var imageInputNoGradient = gradientRemoval(imageInput);

    // Make input image have a Gaussian histogram
    eigenVectors = [];
    for (var i = 0; i < 3; i++)
      eigenVectors[i] = [0, 0, 0];
    var imageInputGaussian = makeHistoGaussianEigen(imageInputNoGradient, eigenVectors);

    // Copy the input image and pre-blend out on borders
    for (var y = 0; y < targetHeight; ++y) {
      for (var x = 0; x < targetWidth; ++x) {
        // Linear interpolation on borders from input to tiles
        var w = Math.min(remapValue(x, 0, borderSize, 0.0, 1.0), 1.0); // Left border
        w *= Math.min(remapValue(x, targetWidth - 1, targetWidth - 1 - borderSize, 0.0, 1.0), 1.0); // Right border
        w *= Math.min(remapValue(y, 0, borderSize, 0.0, 1.0), 1.0); // Top border
        w *= Math.min(remapValue(y, targetHeight - 1, targetHeight - 1 - borderSize, 0.0, 1.0), 1.0); // Bottom border
        w_inv = 1.0 - w;
        // Variance correction
        w = w / Math.sqrt(w * w + w_inv * w_inv);
        output.dataR[y][x] = w * imageInputGaussian.dataR[y][x];
        output.dataG[y][x] = w * imageInputGaussian.dataG[y][x];
        output.dataB[y][x] = w * imageInputGaussian.dataB[y][x];
      }
    }

    // We splat one line of tiles on the top border of the image, and another on the left border
    // The tiles are centered on the edge of the output, and wrapping takes care of the two other borders
    for (var c = -1; c < (tileCountWidth - 1) + (tileCountHeight - 1); ++c) {
      var i_tile, j_tile;
      // Top border tiles
      if (c < tileCountWidth - 1) {
        i_tile = c;
        j_tile = -1;
      }
      // Left border tiles
      else {
        i_tile = -1;
        j_tile = c - (tileCountWidth - 1);
      }

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
      var offset_i = Math.floor((imageInput.width - (tileWidth + tileCenterWidth)) * randXorshiftFloat());
      var offset_j = Math.floor((imageInput.height - (tileHeight + tileCenterHeight)) * randXorshiftFloat());

      // for each pixel of the tile
      for (var j = 0; j < tileHeight + tileCenterHeight; ++j) {
        for (var i = 0; i < tileWidth + tileCenterWidth; ++i) {
          // compute the weight of this pixel of the tile
          // (linear interpolation + variance correction)
          var w = 0

          // Special case for center extension of tiles on top border, only linear blend between center image and this tile
          if (i >= tileWidth / 2 && i < tileWidth / 2 + tileCenterWidth) {
            var w0 = 1.0 - Math.floor(Math.abs(j - 0.5 * (tileHeight - 1))) / (tileHeight / 2 - 1);
            var w1 = 1.0 - w0;
            w = w0 / Math.sqrt(w0 * w0 + w1 * w1);
          }
          // Special case for center extension of tiles on left border, only linear blend between center image and this tile
          else if (j >= tileHeight / 2 && j < tileHeight / 2 + tileCenterHeight) {
            var w0 = 1.0 - Math.floor(Math.abs(i - 0.5 * (tileWidth - 1))) / (tileWidth / 2 - 1);
            var w1 = 1.0 - w0;
            w = w0 / Math.sqrt(w0 * w0 + w1 * w1);
          }
          // Normal case, bilinear blend of this tile, neighbouring tile and center image
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
          var index_i_input = (i + offset_i) % targetWidth;
          var index_j_input = (j + offset_j) % targetHeight;
          output.dataR[index_j_output][index_i_output] +=
            w * imageInputGaussian.dataR[index_j_input][index_i_input];
          output.dataG[index_j_output][index_i_output] +=
            w * imageInputGaussian.dataG[index_j_input][index_i_input];
          output.dataB[index_j_output][index_i_output] +=
            w * imageInputGaussian.dataB[index_j_input][index_i_input];
        }
      }
    }

    // make output image have same histogram as input
    output = unmakeHistoGaussianEigen(output, imageInputNoGradient, eigenVectors);

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

  // input: image
  // performs cheap gradient removal on input
  function gradientRemoval(input) {
    // Allocate output
    var output = { dataR: [], dataG: [], dataB: [], totalWeight: [], width: input.width, height: input.height };
    for (var j = 0; j < output.height; ++j) {
      output.dataR[j] = [];
      output.dataG[j] = [];
      output.dataB[j] = [];
      for (var i = 0; i < output.width; ++i) {
        output.dataR[j][i] = input.dataR[j][i];
        output.dataG[j][i] = input.dataG[j][i];
        output.dataB[j][i] = input.dataB[j][i];
      }
    }

    // Compute mean gradient from left to right over Y and from top to bottom over X
    var gradientX_R = 0.0;
    var gradientX_G = 0.0;
    var gradientX_B = 0.0;
    for (var y = 0; y < input.height; ++y) {
      gradientX_R += input.dataR[y][input.width - 1] - input.dataR[y][0];
      gradientX_G += input.dataG[y][input.width - 1] - input.dataG[y][0];
      gradientX_B += input.dataB[y][input.width - 1] - input.dataB[y][0];
    }
    var gradientY_R = 0.0;
    var gradientY_G = 0.0;
    var gradientY_B = 0.0;
    for (var x = 0; x < input.width; ++x) {
      gradientY_R += input.dataR[input.height - 1][x] - input.dataR[0][x];
      gradientY_G += input.dataG[input.height - 1][x] - input.dataG[0][x];
      gradientY_B += input.dataB[input.height - 1][x] - input.dataB[0][x];
    }
    gradientX_R /= input.height;
    gradientX_G /= input.height;
    gradientX_B /= input.height;
    gradientY_R /= input.width;
    gradientY_G /= input.width;
    gradientY_B /= input.width;

    // Apply high pass filter on input
    for (var y = 0; y < input.height; ++y) {
      for (var x = 0; x < input.width; ++x) {
        var tempX = (-0.5 + x / (input.width - 1));
        var tempY = (-0.5 + y / (input.height - 1));
        var gradientR = tempX * gradientX_R + tempY * gradientY_R
        var gradientG = tempX * gradientX_G + tempY * gradientY_G
        var gradientB = tempX * gradientX_B + tempY * gradientY_B
        output.dataR[y][x] -= gradientR;
        output.dataG[y][x] -= gradientG;
        output.dataB[y][x] -= gradientB;
      }
    }

    return output;
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