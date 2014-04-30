# require 'ansiparse'

# string = string.replace(/.*(\033\[K\n|\r(?!\n))/gm, '')
# string = string.replace(/\033\(B/g, '').replace(/\033\[\d+G/g, '').replace(/\[2K/g, '')
# result.replace(/\033/g, '')

Log.Deansi =
  CLEAR_ANSI: ///
(?:\033) # leader
(?:
    \[0?c                 # query device code
  | \[[0356]n             # device-related
  | \[7[lh]               # disable/enable line wrapping
  | \[\?25[lh]            # not sure what this is, but we've seen it happen
  | \(B                   # set default font to 'B'
  | H                     # set tab at current position
  | \[(?:\d+(;\d+){,2})?G # tab control
  | \[(?:[12])?[JK]       # erase line, screen, etc.
  | [DM]                  # scroll up/down
)
///gm # See http://ispltd.org/mini_howto:ansi_terminal_codes


  apply: (string) ->
    return [] unless string
    string = string.replace(@CLEAR_ANSI, '')
    nodes = ansiparse(string).map (part) => @node(part)
    nodes.push(@node(text: '')) if nodes.length == 0
    nodes

  node: (part) ->
    node = { type: 'span', text: part.text }
    node.class = classes.join(' ') if classes = @classes(part)
    # node.hidden = true   if @hidden(part)
    node

  classes: (part) ->
    result = []
    result = result.concat(@colors(part))
    result if result.length > 0

  colors: (part) ->
    colors = []
    colors.push(part.foreground)         if part.foreground
    colors.push("bg-#{part.background}") if part.background
    colors.push('bold')                  if part.bold
    colors.push('italic')                if part.italic
    colors.push('underline')             if part.underline
    colors

  hidden: (part) ->
    if part.text.match(/\r/)
      part.text = part.text.replace(/^.*\r/gm, '')
      true


