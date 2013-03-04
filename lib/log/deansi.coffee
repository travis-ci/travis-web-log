# require 'ansiparse'

# string = string.replace(/.*(\033\[K\n|\r(?!\n))/gm, '')
# string = string.replace(/\033\(B/g, '').replace(/\033\[\d+G/g, '').replace(/\[2K/g, '')
# result.replace(/\033/g, '')

Log.Deansi =
  apply: (string) ->
    string = string.replace(/\e\[K/g, '')
    nodes = ansiparse(string).map (part) => @node(part)
    nodes.push(@node(text: '')) if nodes.length == 0
    nodes

  node: (part) ->
    if classes = @classes(part)
      { type: 'span', class: classes, text: part.text }
    else
      { type: 'span', text: part.text }

  classes: (part) ->
    result = []
    result.push(part.foreground)         if part.foreground
    result.push("bg-#{part.background}") if part.background
    result.push('bold')                  if part.bold
    result.push('italic')                if part.italic
    result if result.length > 0

