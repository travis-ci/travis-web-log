describe 'simulating test dot output (5 parts, complete permutations)', ->
  beforeEach ->
    log.removeChild(log.firstChild) while log.firstChild
    @log = new Log()
    @render = (parts) -> render(@, parts)

    @html =
      1: strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
        <p><span id="4-0-0">bar</span></p>
      '''
      2: strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
        <p><span id="4-0-0">bar</span></p>
      '''
      3: strip '''
        <p><span id="0-0-0">foo</span></p>
        <p><span id="1-0-0">.</span><span id="2-0-0">.</span><span id="3-0-0">.</span></p>
        <p><span id="4-0-0">bar</span></p>
      '''

  it 'ordered', ->
    expect(@render [[0, 'foo\n'], [1, '.'], [2, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[1]

  it 'unordered (1)', ->
    expect(@render [[0, 'foo\n'], [1, '.'], [2, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (2)', ->
    expect(@render [[0, 'foo\n'], [1, '.'], [3, '.\n'], [2, '.'], [4, 'bar\n']]).toBe @html[1]

  it 'unordered (3)', ->
    expect(@render [[0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n'], [2, '.']]).toBe @html[1]

  it 'unordered (4)', ->
    expect(@render [[0, 'foo\n'], [1, '.'], [4, 'bar\n'], [2, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (4)', ->
    expect(@render [[0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n'], [2, '.']]).toBe @html[3]


  it 'unordered (5)', ->
    expect(@render [[0, 'foo\n'], [2, '.'], [1, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[2]

  it 'unordered (6)', ->
    expect(@render [[0, 'foo\n'], [2, '.'], [1, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (7)', ->
    expect(@render [[0, 'foo\n'], [2, '.'], [3, '.\n'], [1, '.'], [4, 'bar\n']]).toBe @html[2]

  it 'unordered (8)', ->
    expect(@render [[0, 'foo\n'], [2, '.'], [3, '.\n'], [4, 'bar\n'], [1, '.']]).toBe @html[2]

  it 'unordered (9)', ->
    expect(@render [[0, 'foo\n'], [2, '.'], [4, 'bar\n'], [1, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (10)', ->
    expect(@render [[0, 'foo\n'], [2, '.'], [4, 'bar\n'], [3, '.\n'], [1, '.']]).toBe @html[3]


  it 'unordered (11)', ->
    expect(@render [[0, 'foo\n'], [3, '.\n'], [1, '.'], [2, '.'], [4, 'bar\n']]).toBe @html[3]

  it 'unordered (12)', ->
    expect(@render [[0, 'foo\n'], [3, '.\n'], [1, '.'], [4, 'bar\n'], [2, '.']]).toBe @html[3]

  it 'unordered (13)', ->
    expect(@render [[0, 'foo\n'], [3, '.\n'], [2, '.'], [1, '.'], [4, 'bar\n']]).toBe @html[3]

  it 'unordered (14)', ->
    expect(@render [[0, 'foo\n'], [3, '.\n'], [2, '.'], [4, 'bar\n'], [1, '.']]).toBe @html[3]

  it 'unordered (15)', ->
    expect(@render [[0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [1, '.'], [2, '.']]).toBe @html[3]

  it 'unordered (16)', ->
    expect(@render [[0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [2, '.'], [1, '.']]).toBe @html[3]


  it 'unordered (18)', ->
    expect(@render [[0, 'foo\n'], [4, 'bar\n'], [1, '.'], [2, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (19)', ->
    expect(@render [[0, 'foo\n'], [4, 'bar\n'], [1, '.'], [3, '.\n'], [2, '.']]).toBe @html[3]

  it 'unordered (20)', ->
    expect(@render [[0, 'foo\n'], [4, 'bar\n'], [2, '.'], [1, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (21)', ->
    expect(@render [[0, 'foo\n'], [4, 'bar\n'], [2, '.'], [3, '.\n'], [1, '.']]).toBe @html[3]

  it 'unordered (22)', ->
    expect(@render [[0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [1, '.'], [2, '.']]).toBe @html[3]

  it 'unordered (23)', ->
    expect(@render [[0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [2, '.'], [1, '.']]).toBe @html[3]

  # -----------------------

  it 'unordered (24)', ->
    expect(@render [[1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[1]

  it 'unordered (25)', ->
    expect(@render [[1, '.'], [0, 'foo\n'], [2, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (26)', ->
    expect(@render [[1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.'], [4, 'bar\n']]).toBe @html[1]

  it 'unordered (27)', ->
    expect(@render [[1, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [2, '.']]).toBe @html[1]

  it 'unordered (28)', ->
    expect(@render [[1, '.'], [0, 'foo\n'], [4, 'bar\n'], [2, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (29)', ->
    expect(@render [[1, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n'], [2, '.']]).toBe @html[3]


  it 'unordered (30)', ->
    expect(@render [[1, '.'], [2, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n']]).toBe @html[1]

  it 'unordered (31)', ->
    expect(@render [[1, '.'], [2, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (32)', ->
    expect(@render [[1, '.'], [2, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[1]

  it 'unordered (33)', ->
    expect(@render [[1, '.'], [2, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[1]

  it 'unordered (34)', ->
    expect(@render [[1, '.'], [2, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (35)', ->
    expect(@render [[1, '.'], [2, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]


  it 'unordered (36)', ->
    expect(@render [[1, '.'], [3, '.\n'], [0, 'foo\n'], [2, '.'], [4, 'bar\n']]).toBe @html[1]

  it 'unordered (37)', ->
    expect(@render [[1, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [2, '.']]).toBe @html[1]

  it 'unordered (38)', ->
    expect(@render [[1, '.'], [3, '.\n'], [2, '.'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[1]

  it 'unordered (39)', ->
    expect(@render [[1, '.'], [3, '.\n'], [2, '.'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[1]

  it 'unordered (40)', ->
    expect(@render [[1, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [2, '.']]).toBe @html[1]

  it 'unordered (41)', ->
    expect(@render [[1, '.'], [3, '.\n'], [4, 'bar\n'], [2, '.'], [0, 'foo\n']]).toBe @html[1]


  it 'unordered (42)', ->
    expect(@render [[1, '.'], [4, 'bar\n'], [0, 'foo\n'], [2, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (43)', ->
    expect(@render [[1, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [2, '.']]).toBe @html[3]

  it 'unordered (44)', ->
    expect(@render [[1, '.'], [4, 'bar\n'], [2, '.'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (45)', ->
    expect(@render [[1, '.'], [4, 'bar\n'], [2, '.'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]

  it 'unordered (46)', ->
    expect(@render [[1, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [2, '.']]).toBe @html[3]

  it 'unordered (47)', ->
    expect(@render [[1, '.'], [4, 'bar\n'], [3, '.\n'], [2, '.'], [0, 'foo\n']]).toBe @html[3]

  # -----------------------

  it 'unordered (48)', ->
    expect(@render [[2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[2]

  it 'unordered (49)', ->
    expect(@render [[2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (50)', ->
    expect(@render [[2, '.'], [0, 'foo\n'], [3, '.\n'], [1, '.'], [4, 'bar\n']]).toBe @html[2]

  it 'unordered (51)', ->
    expect(@render [[2, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n'], [1, '.']]).toBe @html[2]

  it 'unordered (52)', ->
    expect(@render [[2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (53)', ->
    expect(@render [[2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [4, 'bar\n']]).toBe @html[2]


  it 'unordered (54)', ->
    expect(@render [[2, '.'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [4, 'bar\n']]).toBe @html[2]

  it 'unordered (55)', ->
    expect(@render [[2, '.'], [1, '.'], [0, 'foo\n'], [4, 'bar\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (56)', ->
    expect(@render [[2, '.'], [1, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[2]

  it 'unordered (57)', ->
    expect(@render [[2, '.'], [1, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[2]

  it 'unordered (58)', ->
    expect(@render [[2, '.'], [1, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (59)', ->
    expect(@render [[2, '.'], [1, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]


  it 'unordered (60)', ->
    expect(@render [[2, '.'], [3, '.\n'], [0, 'foo\n'], [1, '.'], [4, 'bar\n']]).toBe @html[2]

  it 'unordered (61)', ->
    expect(@render [[2, '.'], [3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [1, '.']]).toBe @html[2]

  it 'unordered (62)', ->
    expect(@render [[2, '.'], [3, '.\n'], [1, '.'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[2]

  it 'unordered (63)', ->
    expect(@render [[2, '.'], [3, '.\n'], [1, '.'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[2]

  it 'unordered (64)', ->
    expect(@render [[2, '.'], [3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [1, '.']]).toBe @html[2]

  it 'unordered (65)', ->
    expect(@render [[2, '.'], [3, '.\n'], [4, 'bar\n'], [1, '.'], [0, 'foo\n']]).toBe @html[2]


  it 'unordered (66)', ->
    expect(@render [[2, '.'], [4, 'bar\n'], [0, 'foo\n'], [1, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (67)', ->
    expect(@render [[2, '.'], [4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [1, '.']]).toBe @html[3]

  it 'unordered (68)', ->
    expect(@render [[2, '.'], [4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (69)', ->
    expect(@render [[2, '.'], [4, 'bar\n'], [1, '.'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]

  it 'unordered (71)', ->
    expect(@render [[2, '.'], [4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [1, '.']]).toBe @html[3]

  it 'unordered (72)', ->
    expect(@render [[2, '.'], [4, 'bar\n'], [3, '.\n'], [1, '.'], [0, 'foo\n']]).toBe @html[3]

  # -----------------------

  it 'unordered (73)', ->
    expect(@render [[3, '.\n'], [0, 'foo\n'], [1, '.'], [2, '.'], [4, 'bar\n']]).toBe @html[3]

  it 'unordered (74)', ->
    expect(@render [[3, '.\n'], [0, 'foo\n'], [1, '.'], [4, 'bar\n'], [2, '.']]).toBe @html[3]

  it 'unordered (75)', ->
    expect(@render [[3, '.\n'], [0, 'foo\n'], [2, '.'], [1, '.'], [4, 'bar\n']]).toBe @html[3]

  it 'unordered (76)', ->
    expect(@render [[3, '.\n'], [0, 'foo\n'], [2, '.'], [4, 'bar\n'], [1, '.']]).toBe @html[3]

  it 'unordered (77)', ->
    expect(@render [[3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [1, '.'], [2, '.']]).toBe @html[3]

  it 'unordered (78)', ->
    expect(@render [[3, '.\n'], [0, 'foo\n'], [4, 'bar\n'], [2, '.'], [1, '.']]).toBe @html[3]


  it 'unordered (79)', ->
    expect(@render [[3, '.\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [4, 'bar\n']]).toBe @html[3]

  it 'unordered (80)', ->
    expect(@render [[3, '.\n'], [1, '.'], [0, 'foo\n'], [4, 'bar\n'], [2, '.']]).toBe @html[3]

  it 'unordered (81)', ->
    expect(@render [[3, '.\n'], [1, '.'], [2, '.'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[3]

  it 'unordered (82)', ->
    expect(@render [[3, '.\n'], [1, '.'], [2, '.'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[3]

  it 'unordered (83)', ->
    expect(@render [[3, '.\n'], [1, '.'], [4, 'bar\n'], [0, 'foo\n'], [2, '.']]).toBe @html[3]

  it 'unordered (84)', ->
    expect(@render [[3, '.\n'], [1, '.'], [4, 'bar\n'], [2, '.'], [0, 'foo\n']]).toBe @html[3]


  it 'unordered (85)', ->
    expect(@render [[3, '.\n'], [2, '.'], [0, 'foo\n'], [1, '.'], [4, 'bar\n']]).toBe @html[3]

  it 'unordered (86)', ->
    expect(@render [[3, '.\n'], [2, '.'], [0, 'foo\n'], [4, 'bar\n'], [1, '.']]).toBe @html[3]

  it 'unordered (87)', ->
    expect(@render [[3, '.\n'], [2, '.'], [1, '.'], [0, 'foo\n'], [4, 'bar\n']]).toBe @html[3]

  it 'unordered (88)', ->
    expect(@render [[3, '.\n'], [2, '.'], [1, '.'], [4, 'bar\n'], [0, 'foo\n']]).toBe @html[3]

  it 'unordered (89)', ->
    expect(@render [[3, '.\n'], [2, '.'], [4, 'bar\n'], [0, 'foo\n'], [1, '.']]).toBe @html[3]

  it 'unordered (90)', ->
    expect(@render [[3, '.\n'], [2, '.'], [4, 'bar\n'], [1, '.'], [0, 'foo\n']]).toBe @html[3]


  it 'unordered (91)', ->
    expect(@render [[3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [1, '.'], [2, '.']]).toBe @html[3]

  it 'unordered (92)', ->
    expect(@render [[3, '.\n'], [4, 'bar\n'], [0, 'foo\n'], [2, '.'], [1, '.']]).toBe @html[3]

  it 'unordered (92)', ->
    expect(@render [[3, '.\n'], [4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.']]).toBe @html[3]

  it 'unordered (93)', ->
    expect(@render [[3, '.\n'], [4, 'bar\n'], [1, '.'], [2, '.'], [0, 'foo\n']]).toBe @html[3]

  it 'unordered (94)', ->
    expect(@render [[3, '.\n'], [4, 'bar\n'], [2, '.'], [0, 'foo\n'], [1, '.']]).toBe @html[3]

  it 'unordered (95)', ->
    expect(@render [[3, '.\n'], [4, 'bar\n'], [2, '.'], [1, '.'], [0, 'foo\n']]).toBe @html[3]

  # -----------------------

  it 'unordered (96)', ->
    expect(@render [[4, 'bar\n'], [0, 'foo\n'], [1, '.'], [2, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (97)', ->
    expect(@render [[4, 'bar\n'], [0, 'foo\n'], [1, '.'], [3, '.\n'], [2, '.']]).toBe @html[3]

  it 'unordered (98)', ->
    expect(@render [[4, 'bar\n'], [0, 'foo\n'], [2, '.'], [1, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (99)', ->
    expect(@render [[4, 'bar\n'], [0, 'foo\n'], [2, '.'], [3, '.\n'], [1, '.']]).toBe @html[3]

  it 'unordered (100)', ->
    expect(@render [[4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [1, '.'], [2, '.']]).toBe @html[3]

  it 'unordered (101)', ->
    expect(@render [[4, 'bar\n'], [0, 'foo\n'], [3, '.\n'], [2, '.'], [1, '.']]).toBe @html[3]


  it 'unordered (102)', ->
    expect(@render [[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (103)', ->
    expect(@render [[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.']]).toBe @html[3]

  it 'unordered (104)', ->
    expect(@render [[4, 'bar\n'], [1, '.'], [2, '.'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (105)', ->
    expect(@render [[4, 'bar\n'], [1, '.'], [2, '.'], [3, '.\n'], [0, 'foo\n']]).toBe @html[3]

  it 'unordered (106)', ->
    expect(@render [[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [3, '.\n'], [2, '.']]).toBe @html[3]

  it 'unordered (107)', ->
    expect(@render [[4, 'bar\n'], [1, '.'], [0, 'foo\n'], [2, '.'], [3, '.\n']]).toBe @html[1]


  it 'unordered (108)', ->
    expect(@render [[4, 'bar\n'], [2, '.'], [0, 'foo\n'], [1, '.'], [3, '.\n']]).toBe @html[3]

  it 'unordered (109)', ->
    expect(@render [[4, 'bar\n'], [2, '.'], [0, 'foo\n'], [3, '.\n'], [1, '.']]).toBe @html[3]

  it 'unordered (110)', ->
    expect(@render [[4, 'bar\n'], [2, '.'], [1, '.'], [0, 'foo\n'], [3, '.\n']]).toBe @html[3]

  it 'unordered (111)', ->
    expect(@render [[4, 'bar\n'], [2, '.'], [1, '.'], [3, '.\n'], [0, 'foo\n']]).toBe @html[2]

  it 'unordered (112)', ->
    expect(@render [[4, 'bar\n'], [2, '.'], [3, '.\n'], [0, 'foo\n'], [1, '.']]).toBe @html[2]

  it 'unordered (113)', ->
    expect(@render [[4, 'bar\n'], [2, '.'], [3, '.\n'], [1, '.'], [0, 'foo\n']]).toBe @html[2]

  it 'unordered (114)', ->
    expect(@render [[4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [1, '.'], [2, '.']]).toBe @html[3]

  it 'unordered (115)', ->
    expect(@render [[4, 'bar\n'], [3, '.\n'], [0, 'foo\n'], [2, '.'], [1, '.']]).toBe @html[3]

  it 'unordered (116)', ->
    expect(@render [[4, 'bar\n'], [3, '.\n'], [1, '.'], [0, 'foo\n'], [2, '.']]).toBe @html[3]

  it 'unordered (117)', ->
    expect(@render [[4, 'bar\n'], [3, '.\n'], [1, '.'], [2, '.'], [0, 'foo\n']]).toBe @html[3]

  it 'unordered (118)', ->
    expect(@render [[4, 'bar\n'], [3, '.\n'], [2, '.'], [0, 'foo\n'], [1, '.']]).toBe @html[3]

  it 'unordered (119)', ->
    expect(@render [[4, 'bar\n'], [3, '.\n'], [2, '.'], [1, '.'], [0, 'foo\n']]).toBe @html[3]



