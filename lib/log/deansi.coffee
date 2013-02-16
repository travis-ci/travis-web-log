require 'ansiparse'

Log.Deansi =
  apply: (string) ->
    string = string.replace(/.*(\033\[K\n|\r(?!\n))/gm, '')
    # string = string.replace(/\033\(B/g, '').replace(/\033\[\d+G/g, '').replace(/\[2K/g, '')
    result = []
    ansiparse(string).forEach (part) =>
      result.push(@node(part))
    # result.replace(/\033/g, '')
    result

  classes: (part) ->
    result = []
    result.push(part.foreground)         if part.foreground
    result.push("bg-#{part.background}") if part.background
    result.push('bold')                  if part.bold
    result.push('italic')                if part.italic
    result if result.length > 0

  node: (part) ->
    if classes = @classes(part)
      { type: 'span', class: classes, text: part.text }
    else
      { type: 'text', text: part.text }


