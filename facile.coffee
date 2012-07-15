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
  if cb
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
  else
    for key, value of data
      bindOrRemove($template, key, resolve(value))
    $template.html()

# Compile method for using in Express
facile.compile = (template, options) ->
  (locals) -> facile(template, locals)

bindOrRemove = ($template, key, value, cb) ->
  if value?
    bindData($template, key, value, cb)
  else
    $el = find($template, key)
    $el.remove()
    cb() if cb

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
    cb() if cb
    return

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
        if cb
          facile $clone, arrayValue, (err, newHtml) ->
            return cb(err) if err
            $root.append(newHtml)
            peel()
        else
          newHtml = facile($clone, arrayValue)
          $root.append(newHtml)
          peel()
      else
        if cb
          resolve arrayValue, (err, val) ->
            return cb(err) if err
            $clone.html val
            $root.before $clone
            peel()
        else
          $clone.html(resolve arrayValue)
          $root.before($clone)
          peel()
    else
      cb() if cb
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
  cb() if cb

bindNestedObject = ($template, key, value, cb) ->
  if cb
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
    for attr, attrValue of value
      bindOrRemove($template, attr, resolve attrValue)

bindAttributeObject = ($template, key, value, cb) ->
  if cb
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
      peel()

  else
    $template.html(resolve value.content)
    for attr, attrValue of value when attr != 'content'
      val = resolve attrValue
      if attr == 'class'
        $template.attr('class', combineClasses($template.attr('class'), val))
      else
        $template.attr(attr, val)

resolve = (functionOrValue, cb) ->
  if isFunction functionOrValue
    if cb
      if functionOrValue.length == 1
        functionOrValue(cb)
      else
        try
          result = functionOrValue()
          cb null, result
        catch e
          cb e
    else
      functionOrValue()
  else
    if cb then cb(null, functionOrValue) else functionOrValue

isFunction = (obj) ->
  !!(obj && obj.constructor && obj.call && obj.apply)

if this.window
  window.facile = facile
else
  module.exports = facile
