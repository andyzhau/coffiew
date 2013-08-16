# Constants used by coffiew compiler.
#
# Author: Andy Zhao(andy@nodeswork.com)

module.exports =

  # Values available to the `doctype` function inside a template.
  # Ex.: `doctype 'strict'`
  doctypes:
    default: '<!DOCTYPE html>'
    5: '<!DOCTYPE html>'
    xml: '<?xml version="1.0" encoding="utf-8" ?>'
    transitional: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    strict: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    frameset: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
    1.1: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
    basic: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
    mobile: '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
    ce: '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd">'

  # Private HTML element reference.
  # Please mind the gap (1 space at the beginning of each subsequent line).
  elements:
    # Valid HTML 5 elements requiring a closing tag.
    # Note: the `var` element is out for obvious reasons, please use `tag 'var'`.
    regular: 'a abbr address article aside audio b bdi bdo blockquote body button
 canvas caption cite code colgroup datalist dd del details dfn div dl dt em
 fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
 html i iframe ins kbd label legend li main map mark menu meter nav noscript object
 ol optgroup option output p pre progress q rp rt ruby s samp script section
 select small span strong style sub summary sup table tbody td textarea tfoot
 th thead time title tr u ul video'

   # Support for SVG 1.1 tags
    svg: 'a altGlyph altGlyphDef altGlyphItem animate animateColor animateMotion
 animateTransform circle clipPath color-profile cursor defs desc ellipse
 feBlend feColorMatrix feComponentTransfer feComposite feConvolveMatrix
 feDiffuseLighting feDisplacementMap feDistantLight feFlood feFuncA feFuncB
 feFuncG feFuncR feGaussianBlur feImage feMerge feMergeNode feMorphology
 feOffset fePointLight feSpecularLighting feSpotLight feTile feTurbulence
 filter font font-face font-face-format font-face-name font-face-src
 font-face-uri foreignObject g glyph glyphRef hkern image line linearGradient
 marker mask metadata missing-glyph mpath path pattern polygon polyline
 radialGradient rect script set stop style svg symbol text textPath
 title tref tspan use view vkern'

    # Valid self-closing HTML 5 elements.
    void: 'area base br col command embed hr img input keygen link meta param source track wbr'

    # Support for xml sitemap elements
    xml: 'urlset url loc lastmod changefreq priority'

    obsolete: 'applet acronym bgsound dir frameset noframes isindex listing
 nextid noembed plaintext rb strike xmp big blink center font marquee multicol
 nobr spacer tt'

    obsolete_void: 'basefont frame'
