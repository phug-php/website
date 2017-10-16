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
      return
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
      return
    do dumpGroup
    return
  $('.table-of-content').append tableOfContents
  $('body').scrollspy
    target: '#contents'
    offset: Math.round $('main').css('padding-top').replace('px','')
  $(document)
    .on 'scroll', ->
      scrollTop = $(@).scrollTop() - 10
      $('.chapter').each ->
        $chapter = $ @
        top = $(@).offset().top
        method = if top <= scrollTop and top + $chapter.height() >= scrollTop
          'addClass'
        else
          'removeClass'
        $chapter.find('.edit-btn:visible')[method] 'sticky-button'
        return
      return
    .on 'click', '[data-close]', ->
      $('#' + $(@).data('close')).removeClass 'opened'
      return
    .on 'click', '[data-toggle]', ->
      $('#' + $(@).data('toggle')).toggleClass 'opened'
      return
    .on 'click', '[data-toggle="offcanvas"]', ->
      $('.navbar-toggler, .sidebar').toggleClass 'show'
      return
  return
