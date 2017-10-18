window.Popper = {}
$ ->
  tableOfContents = []
  $('main').find('.chapter').each ->
    $section = $ @
    sectionId = $section.attr 'id'
    $section.removeAttr 'id'
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
      $header.attr 'id', id
      $a = $ '<a>'
      $a.text headerText
      $a.prop 'href', '#' + id
      $a.data 'action', 'sidebar-nav'
      $a.addClass 'nav-link'
      if isH1
        tableOfContents.push $a
      else
        group.push $a
      return
    do dumpGroup
    $section.find('pre > code').filter('.language-phug, .language-pug').each ->
      $code = $ @
      $pre = $code.parent()
      lineHeight = 14
      code = $pre.text()
      outputLines = code.split(/\n/g).length
      lines = outputLines + 4
      vars = ''
      $vars = $pre.next()
      if $vars.is 'pre'
        vars = $vars.find('> code.language-vars').html()
      if vars
        varsLines = vars.split(/\n/g).length
        lines += varsLines
        $vars.remove()
      $pre.replaceWith '<iframe src="https://pug-demo.herokuapp.com/' +
        '?embed&theme=xcode&border=silver&options-color=rgba(120,120,120,0.5)' +
        '&engine=' + ($code.is('language-phug') ? 'phug' : 'pug-php') +
        '&input=' + encodeURIComponent(code) +
        (if vars
          '&vars=' + encodeURIComponent(vars) + '&vars-height=' + (varsLines * 100 / (outputLines + 2 + varsLines))
        else
          '&hide-vars'
        ) +
        '" class="live-code" style="height: ' + Math.max(158, lines * lineHeight + 2) + 'px;">'
      return
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
