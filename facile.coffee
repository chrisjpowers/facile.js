$ = this.$ || require "cheerio"

find = ($el, key) ->
  $result = $el.find('#' + key)
  $result = $el.find('.' + key) if $result.length == 0
  $result

combineClasses = (existingClasses, newClasses) ->
  if existingClasses
    if newClasses.length > 0
      "#{existingClasses} #{newClasses}"
    else
      existingClasses
  else
    newClasses

facile = (template, data, cb) ->
  $template = $('<div />').append($(template))
  output = null
  cb ?= (err, str) ->
    throw err if err
    output = str
  tuples = ([key, val] for key, val of data)
  peel = ->
    if tuples.length > 0
      [key, val] = tuples.shift()
      resolve val, (err, value) ->
        return cb(err) if err
        bindOrRemove $template, key, value, (err) ->
          return cb(err) if err
          peel()
    else
      cb null, $template.html()
  peel()
  output

# Compile method for using in Express
facile.compile = (template, options) ->
  (locals) -> facile(template, locals)

bindOrRemove = ($template, key, value, cb) ->
  if value?
    bindData($template, key, value, cb)
  else
    $el = find($template, key)
    $el.remove()
    cb()

bindData = ($template, key, value, cb) ->
  if value.constructor == Array
    bindArray($template, key, value, cb)
  else if value.constructor == Object
    $target = find($template, key)
    bindObject($target, key, value, cb)
  else
    bindValue($template, key, value, cb)

bindArray = ($template, key, value, cb) ->
  $root = find($template, key)
  if $root.length == 0
    return cb()

  $nested = find($root, key)
  if $nested.length > 0
    $root = $nested

  if tagName($root) == "TABLE"
    $root = $root.find('tbody')

  $child = $root.children().remove()

  index = 0
  peel = ->
    if index < value.length
      arrayValue = value[index]
      index++
      $clone = $child.clone()
      if arrayValue.constructor == Object
        facile $clone, arrayValue, (err, newHtml) ->
          return cb(err) if err
          $root.append(newHtml)
          peel()
      else
        resolve arrayValue, (err, val) ->
          return cb(err) if err
          $clone.html val
          $root.before $clone
          peel()
    else
      cb()
  peel()

bindObject = ($template, key, value, cb) ->
  if value.content?
    bindAttributeObject($template, key, value, cb)
  else
    bindNestedObject($template, key, value, cb)

tagName = ($el) ->
  if $el.prop
    $el.prop "tagName"
  else
    $el[0].name.toUpperCase()

bindValue = ($template, key, value, cb) ->
  if key.indexOf('@') != -1
    [key, attr] = key.split('@')
    $el = find($template, key)
    if tagName($el) == 'SELECT'
      $el.find("option[value='#{value}']").attr('selected', 'selected')
    else
      $el.attr(attr, value)
  else
    $el = find($template, key)
    if $el.length > 0
      if tagName($el) == 'INPUT' && $el.attr('type') == 'checkbox' && value
        $el.attr('checked', "checked")
      else if tagName($el) == 'INPUT' || tagName($el) == 'OPTION'
        $el.attr('value', '' + value)
      else if tagName($el) == 'SELECT' && value.constructor != Object
        $el.find("option[value='#{value}']").attr('selected', 'selected')
      else
        $el.html('' + value)
  cb()

bindNestedObject = ($template, key, value, cb) ->
  tuples = ([attr, attrValue] for attr, attrValue of value)
  peel = ->
    if tuples.length > 0
      [attr, attrValue] = tuples.shift()
      resolve attrValue, (err, resolvedValue) ->
        return cb(err) if err
        bindOrRemove $template, attr, resolvedValue, (err) ->
          return cb(err) if err
          peel()
    else
      cb()
  peel()

bindAttributeObject = ($template, key, value, cb) ->
  resolve value.content, (err, content) ->
    return cb(err) if err
    $template.html(content)

    tuples = ([attr, attrValue] for attr, attrValue of value)
    peel = ->
      if tuples.length > 0
        [attr, attrValue] = tuples.shift()
        return peel() if attr == "content"
        resolve attrValue, (err, val) ->
          return cb(err) if err
          if attr == 'class'
            $template.attr('class', combineClasses($template.attr('class'), val))
          else
            $template.attr(attr, val)
          peel()
      else
        cb()
    peel()

resolve = (functionOrValue, cb) ->
  if isFunction functionOrValue
    if functionOrValue.length == 1
      functionOrValue(cb)
    else
      try
        result = functionOrValue()
        cb null, result
      catch e
        cb e
  else
    cb(null, functionOrValue)

isFunction = (obj) ->
  !!(obj && obj.constructor && obj.call && obj.apply)

if this.window
  window.facile = facile
else
  module.exports = facile
