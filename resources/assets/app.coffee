window.Popper = {}
$ ->
  tableOfContents = []
  $('main').find('.chapter').each ->
    $section = $ @
    sectionId = $section.attr 'id'
    group = []
    $section.prepend $('#edit-btn').html().replace /\{id\}/g, sectionId
    dumpGroup = ->
      if group.length
        $nav = $ '<nav class="nav flex-column">'
        $nav.append group
        tableOfContents.push $nav
        group = []
    $section.find('h1, h2').each ->
      $header = $ @
      isH1 = $header.is 'h1'
      if isH1
        do dumpGroup
      headerText = $header.text()
      id = headerText.toLowerCase().replace /[^a-z0-9]+/g, '-'
      anchor = sectionId + '-' + id
      $header.attr 'id', anchor
      $a = $ '<a>'
      $a.text headerText
      $a.prop 'href', '#' + anchor
      $a.data 'action', 'sidebar-nav'
      $a.addClass 'nav-link'
      if isH1
        tableOfContents.push $a
      else
        group.push $a
    do dumpGroup
  $('.table-of-content').append tableOfContents
  $('body').scrollspy
    target: '#contents'
    offset: Math.round $('main').css('padding-top').replace('px','')
  $(document)
    .on 'click', '[data-close]', ->
      $('#' + $(@).data('close')).removeClass 'opened'
    .on 'click', '[data-toggle]', ->
      $('#' + $(@).data('toggle')).toggleClass 'opened'
