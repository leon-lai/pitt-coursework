/*
 * Filter Studio Back-end
 * ===========================================================================
 * JavaScript is a pretty neat programming language compared to Java, which I
 * am used to. For example, functions are objects, so that functions can
 * return functions. This assignment presented me an opportunity to explore
 * JavaScript and DOM events handling.
 * ---------------------------------------------------------------------------
 * Limitations:
 * - Cannot handle more than 2^53 (largest consecutive integer in double-
 *   precision floating-point format) filter primitive-related elements
 *   simultaneously existing in the document.
 * - Cannot set the "result" attribute.
 * - The "in" attribute control is not a menu.
 * - Entering invalid attribute values will not make the program produce error
 *   messages.
 * - No animation.
 */

/**
 * Constructs an Object that is a standalone back-end of Filter Studio.
 */
function FilterStudio(filtered, filter, form) {
	/*
	 * Helper methods
	 */
	var createSVGElement = function(tagName) {
		return document.createElementNS("http://www.w3.org/2000/svg", tagName);
	};
	var createXHTMLElement = function(tagName) {
		return document.createElementNS("http://www.w3.org/1999/xhtml", tagName);
	};
	var createTextNode = function(data) {
		return document.createTextNode(data);
	};
	var commonControl = function(module, tagName, legendText) {
		var legend = createXHTMLElement("legend"),
		    incinerateButton = createXHTMLElement("button"),
		    incinerate;
		legend.appendChild(createTextNode(legendText + " "));
		incinerateButton.setAttribute("title", "remove " + legendText);
		incinerateButton.appendChild(createTextNode("X"));
		incinerate = function(module) {
			/*
			 * I hope this is enough to delete a module completely.
			 */
			module.fe.parentNode.removeChild(module.fe);
			module.fieldset.parentNode.removeChild(module.fieldset);
			feCount--;
			if(feCount == 0) {
				filtered.removeAttribute("filter");
			}
		}
		incinerateButton.addEventListener("click", function(){incinerate(module);});
		incinerateButton.addEventListener("touch", function(){incinerate(module);});
		legend.appendChild(incinerateButton);
		module.fe = createSVGElement(tagName);
		module.fieldset = createXHTMLElement("fieldset");
		module.fieldset.appendChild(legend);
		feCount++;
		if(feCount > 0 && !filtered.hasAttribute("filter")) {
			filtered.setAttribute("filter", filteredBy);
		}
	};
	var lightSourceCommonControl = function(module, tagName) {
		module.fe = createSVGElement(tagName);
		module.fieldset = createXHTMLElement("fieldset");
	};
	var lazyControl = function(module, attribute, valueList) {
		var attributeControl, label, errorspan;
		if(valueList === undefined) {
			attributeControl = createXHTMLElement("input");
		}
		else {
			attributeControl = createXHTMLElement("select");
			valueList = [""].concat(valueList);
			for(var i = 0; i < valueList.length; i++) {
				var value, option;
				value = valueList[i];
				option = createXHTMLElement("option");
				option.appendChild(createTextNode(value));
				option.setAttribute("value", value);
				attributeControl.appendChild(option);
			}
		}
		errorspan = createXHTMLElement("span");
		errorspan.classList.add("errorspan");
		attributeControl.addEventListener("change", function() {
			try {
				if (this.value === "" && module.fe.hasAttribute(attribute)) {
					module.fe.removeAttribute(attribute);
				}
				else {
					module.fe.setAttribute(attribute, this.value);
				}
			}
			catch(error) { /* Invalid attribute value error catching does not work. Why? */
				errorspan.innerHTML = error;
			}
		});
		attributeControl.setAttribute("name", attribute);
		label = createXHTMLElement("label");
		label.appendChild(createTextNode(attribute + ": "));
		label.appendChild(attributeControl);
		label.appendChild(createTextNode(" "));
		label.appendChild(errorspan);
		module.fieldset.appendChild(label);
		module["set" + attribute.charAt(0).toUpperCase() + attribute.slice(1)] = function($) {
			attributeControl.value = $;
			attributeControl.dispatchEvent((function(){
				var change = document.createEvent("HTMLEvents");
				change.initEvent("change", true, true);
				return change;
			})());
		}
		return label;
	};
	/*
	 * General methods
	 */
	var createFilterStudioModule = function(tagNames, tagName, filter, createMenu) {
		var module = new tagNames[tagName]();
		filter.appendChild(module.fe);
		createMenu.parentNode.insertBefore(module.fieldset, createMenu);
		return module;
	};
	var createCreateMenu = function(tagNames, filter, form, text) {
		var createMenu, option;
		createMenu = createXHTMLElement("select");
		option = createXHTMLElement("option");
		option.value = "";
		option.appendChild(createTextNode("Create new " + text + "…"));
		createMenu.appendChild(option);
		for(var tagName in tagNames) {
			option = createXHTMLElement("option");
			option.value = tagName;
			option.appendChild(createTextNode(tagName));
			createMenu.appendChild(option);
		}
		createMenu.classList.add("createMenu");
		createMenu.addEventListener("change", function() {
			createFilterStudioModule(tagNames, createMenu.value, filter, createMenu);
			createMenu.value = "";
		});
		form.appendChild(createMenu);
		return createMenu;
	};
	var createSelectLightSourceMenu = function(module) {
		var menu, option;
		menu = createXHTMLElement("select");
		option = createXHTMLElement("option");
		option.value = "";
		option.appendChild(createTextNode("Select light source…"));
		menu.appendChild(option);
		for(var tagName in lightSourceElements) {
			option = createXHTMLElement("option");
			option.value = tagName;
			option.appendChild(createTextNode(tagName));
			menu.appendChild(option);
		}
		menu.classList.add("createMenu");
		menu.addEventListener("change", function() {
			if(module.lightSource) {
				module.fieldset.removeChild(module.lightSource.fieldset);
				module.fe.removeChild(module.lightSource.fe);
				module.lightSource = undefined;
			}
			if(menu.value !== "") {
				module.lightSource = new lightSourceElements[menu.value]();
				module.fe.appendChild(module.lightSource.fe);
				module.fieldset.insertBefore(module.lightSource.fieldset, menu.nextSibling);
			}
		});
		module.fieldset.appendChild(menu);
		return menu;
	};
	var createCreateFeMergeNodeButton = function(filter, form) {
		var button = createXHTMLElement("button"), newnode;
		newnode = function() {
			createFilterStudioModule({feMergeNode: feMergeNode}, "feMergeNode", filter, button);
		};
		button.appendChild(createTextNode("Create new feMergeNode"));
		button.classList.add("createMenu");
		button.addEventListener("click", function(){newnode()});
		button.addEventListener("touch", function(){newnode()});
		form.appendChild(button);
		return button;
	};
	/*
	 * "filter" attribute of filtered element
	 */
	var filteredBy = filtered.getAttribute("filter");
	/*
	 * Filter primitive-related elements grand tally
	 */
	var feCount = 0;
	/*
	 * Filter primitive element creation tallies
	 */
	var creationCountFor = {
		feBlend: 0,
		feColorMatrix: 0,
		feComponentTransfer: 0,
		feComposite: 0,
		feConvolveMatrix: 0,
		feDiffuseLighting: 0,
		feDisplacementMap: 0,
		feFlood: 0,
		feGaussianBlur: 0,
		feImage: 0,
		feMerge: 0,
		feMorphology: 0,
		feOffset: 0,
		feSpecularLighting: 0,
		feTile: 0,
		feTurbulence: 0
	};
	/*
	 * Light source elements
	 */
	var lightSourceElements = {
		feDistantLight: function feDistantLight() {
			var tagName = "feDistantLight";
			lightSourceCommonControl(this, tagName);
			lazyControl(this, "azimuth");
			lazyControl(this, "elevation");
		},
		fePointLight: function fePointLight() {
			var tagName = "fePointLight";
			lightSourceCommonControl(this, tagName);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "z");
		},
		feSpotLight: function feSpotLight() {
			var tagName = "feSpotLight";
			lightSourceCommonControl(this, tagName);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "z");
			lazyControl(this, "pointsAtX");
			lazyControl(this, "pointsAtY");
			lazyControl(this, "pointsAtZ");
			lazyControl(this, "specularExponent");
			lazyControl(this, "limitingConeAngle");
		}
	};
	/*
	 * Transfer function elements
	 */
	var transferFunctionElements = {
		feFuncR: function feFuncR() {
			var tagName = "feFuncR";
			commonControl(this, tagName, tagName);
			lazyControl(this, "type", ["identity", "table", "discrete", "linear", "gamma"]);
			lazyControl(this, "tableValues");
			lazyControl(this, "slope");
			lazyControl(this, "intercept");
			lazyControl(this, "amplitude");
			lazyControl(this, "exponent");
			lazyControl(this, "offset");
		},
		feFuncG: function feFuncG() {
			var tagName = "feFuncG";
			commonControl(this, tagName, tagName);
			lazyControl(this, "type", ["identity", "table", "discrete", "linear", "gamma"]);
			lazyControl(this, "tableValues");
			lazyControl(this, "slope");
			lazyControl(this, "intercept");
			lazyControl(this, "amplitude");
			lazyControl(this, "exponent");
			lazyControl(this, "offset");
		},
		feFuncB: function feFuncB() {
			var tagName = "feFuncB";
			commonControl(this, tagName, tagName);
			lazyControl(this, "type", ["identity", "table", "discrete", "linear", "gamma"]);
			lazyControl(this, "tableValues");
			lazyControl(this, "slope");
			lazyControl(this, "intercept");
			lazyControl(this, "amplitude");
			lazyControl(this, "exponent");
			lazyControl(this, "offset");
		},
		feFuncA: function feFuncA() {
			var tagName = "feFuncA";
			commonControl(this, tagName, tagName);
			lazyControl(this, "type", ["identity", "table", "discrete", "linear", "gamma"]);
			lazyControl(this, "tableValues");
			lazyControl(this, "slope");
			lazyControl(this, "intercept");
			lazyControl(this, "amplitude");
			lazyControl(this, "exponent");
			lazyControl(this, "offset");
		}
	};
	/*
	 * feMergeNode
	 */
	var feMergeNode = function feMergeNode() {
		var tagName = "feMergeNode";
		commonControl(this, tagName, tagName);
		lazyControl(this, "in");
	};
	/*
	 * Filter primitive elements
	 */
	var filterPrimitiveElements = {
		feBlend: function feBlend() {
			var tagName = "feBlend",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			lazyControl(this, "mode", ["normal", "multiply", "screen", "darken", "lighten"]);
			lazyControl(this, "in2");
		},
		feColorMatrix: function feColorMatrix() {
			var tagName = "feColorMatrix",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			lazyControl(this, "type", ["matrix", "saturate", "hueRotate", "luminanceToAlpha"]);
			lazyControl(this, "values");
		},
		feComponentTransfer: function feComponentTransfer() {
			var tagName = "feComponentTransfer",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			createCreateMenu(transferFunctionElements, this.fe, this.fieldset, "transfer function");
		},
		feComposite: function feComposite() {
			var tagName = "feComposite",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			lazyControl(this, "operator", ["over", "in", "out", "atop", "xor", "arithmetic"]);
			lazyControl(this, "k1");
			lazyControl(this, "k2");
			lazyControl(this, "k3");
			lazyControl(this, "k4");
			lazyControl(this, "in2");
		},
		feConvolveMatrix: function feConvolveMatrix() {
			var tagName = "feConvolveMatrix",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			lazyControl(this, "order");
			lazyControl(this, "kernelMatrix");
			lazyControl(this, "divisor");
			lazyControl(this, "bias");
			lazyControl(this, "targetX");
			lazyControl(this, "targetY");
			lazyControl(this, "edgeMode", ["duplicate", "wrap", "none"]);
			lazyControl(this, "kernelUnitLength");
			lazyControl(this, "preserveAlpha", ["false", "true"]);
		},
		feDiffuseLighting: function feDiffuseLighting() {
			var tagName = "feDiffuseLighting",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			createSelectLightSourceMenu(this);
			lazyControl(this, "surfaceScale");
			lazyControl(this, "diffuseConstant");
			lazyControl(this, "kernelUnitLength");
		},
		feDisplacementMap: function feDisplacementMap() {
			var tagName = "feDisplacementMap",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			lazyControl(this, "scale");
			lazyControl(this, "xChannelSelector", ["R", "G", "B", "A"]);
			lazyControl(this, "yChannelSelector", ["R", "G", "B", "A"]);
			lazyControl(this, "in2");
		},
		feFlood: function feFlood() {
			var tagName = "feFlood",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "flood-color");
			lazyControl(this, "flood-opacity");
		},
		feGaussianBlur: function feGaussianBlur() {
			var tagName = "feGaussianBlur",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			lazyControl(this, "stdDeviation");
		},
		feImage: function feImage() {
			var tagName = "feImage",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "xlink:href");
			lazyControl(this, "preserveAspectRatio");
		},
		feMerge: function feMerge() {
			var tagName = "feMerge",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			createCreateFeMergeNodeButton(this.fe, this.fieldset);
		},
		feMorphology: function feMorphology() {
			var tagName = "feMorphology",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			lazyControl(this, "operator", ["erode", "dilate"]);
			lazyControl(this, "radius");
		},
		feOffset: function feOffset() {
			var tagName = "feOffset",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			lazyControl(this, "dx");
			lazyControl(this, "dy");
		},
		feSpecularLighting: function feSpecularLighting() {
			var tagName = "feSpecularLighting",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
			createSelectLightSourceMenu(this);
			lazyControl(this, "surfaceScale");
			lazyControl(this, "specularConstant");
			lazyControl(this, "specularExponent");
			lazyControl(this, "kernelUnitLength");
		},
		feTile: function feTile() {
			var tagName = "feTile",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "in");
		},
		feTurbulence: function feTurbulence() {
			var tagName = "feTurbulence",
			    result = tagName + "-" + creationCountFor[tagName]++;
			commonControl(this, tagName, result);
			this.fe.setAttribute("result", result);
			lazyControl(this, "x");
			lazyControl(this, "y");
			lazyControl(this, "width");
			lazyControl(this, "height");
			lazyControl(this, "baseFrequency");
			lazyControl(this, "numOctaves");
			lazyControl(this, "seed");
			lazyControl(this, "stitchTiles", ["stitch", "noStitch"]);
			lazyControl(this, "type", ["fractalNoise", "turbulence"]);
		}
	};
	/**
	 * Creates and returns a filter studio module.
	 */
	this.create = function(tagName) {
		return createFilterStudioModule(filterPrimitiveElements, tagName, filter, createMenu);
	};
	/**
	 * Set up create menu.
	 */
	var createMenu = createCreateMenu(filterPrimitiveElements, filter, form, "filter primitive");
}
window.addEventListener("load", function() {
	var fs = new FilterStudio(document.getElementsByTagName("image")[0], document.getElementById("filter"), document.getElementById("form")),
	    demofpe = fs.create("feConvolveMatrix");
	/*
	 * Set image
	 */
	document.getElementById("imagehref").addEventListener("change", function() {
		document.getElementsByTagName("image")[0].setAttributeNS("http://www.w3.org/1999/xlink", "href", this.value);
	});
	document.getElementById("imagehref").value = "PittSkyline082904.jpg";
	document.getElementById("imagehref").dispatchEvent((function(){
		var change = document.createEvent("HTMLEvents");
		change.initEvent("change", true, true);
		return change;
	})());
	/*
	 * Make a demo filter primitive element.
	 */
	demofpe.setOrder("3 3");
	demofpe.setPreserveAlpha("true");
	demofpe.setKernelMatrix("-1 -1 -1 -1 8 -1 -1 -1 -1");
});

/*
 * References
 *
 * http://w3.org/TR/SVG/filters.html
 * http://w3schools.com/xml/met_document_createelementns.asp
 * http://w3.org/TR/html4/interact/forms.html#h-17.9.1
 * http://w3schools.com/js/js_function_closures.asp
 * http://w3schools.com/js/js_object_definition.asp
 * http://w3schools.com/jsref/prop_element_classlist.asp
 * http://w3schools.com/jsref/jsref_slice_string.asp
 * https://stackoverflow.com/questions/2490825
 * http://w3.org/TR/DOM-Level-2-Events/events.html#Events-Registration-interfaces
 * http://w3schools.com/js/js_errors.asp
 * http://w3schools.com/jsref/met_node_insertbefore.asp
 * http://w3schools.com/xml/met_element_insertbefore.asp
 * http://w3schools.com/Dom/met_element_setattributens.asp
 * http://w3schools.com/jsref/prop_node_nextsibling.asp
 */
