if /phug-lang\.com$/.test location.host
  document.domain = 'phug-lang.com'
window.Popper = {}
$ ->
  tableOfContents = []
  ids = {}
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
    $section.find('h1, h2, h3').each ->
      $header = $ @
      headerText = $header.text()
      id = removeDiacritics(headerText).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+/, '').replace(/-+$/, '')
      if ids[id]
        id = sectionId + '-' + id
      if ids[id]
        baseId = id + '-'
        i = 2
        while ids[baseId + i]
          i++
        id = baseId + i
      ids[id] = true
      $header.attr 'id', id
      $header.append '&nbsp; <a class="header-anchor" href="#' + id + '">¶</a>'
      if $header.is 'h3'
        return
      isH1 = $header.is 'h1'
      if isH1
        do dumpGroup
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
    selector = (('.language-' + lang) for lang in ['phug', 'pug', 'css', 'js', 'javascript', 'markdown']).join(', ')
    $section.find('pre > code').filter(selector).each ->
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
      minHeight = 100
      if vars
        minHeight = 158
        varsLines = vars.split(/\n/g).length
        lines += varsLines
        $vars.remove()
      fileName = code.match /^(#|\/\*|\/\/-?)\s*([\w\/-]+\.\w{2,4})\s*(\*\/)?\n/
      language = null
      if $code.hasClass('language-js') or $code.hasClass('language-javascript')
        language = 'javascript'
      else if $code.hasClass('language-css')
        language = 'css'
      else if $code.hasClass('language-markdown')
        language = 'markdown'
      saveAs = if fileName
        fileName[2]
      else
        ''
      $next = $pre.next()
      options = $next.find('i:first').data('options') || {}
      if options.static
        return
      $next.find('i[data-options]').remove()
      if ($next.html() || '').trim() is ''
        $next.remove()
      $pre.replaceWith '<iframe data-src="https://pug-demo.herokuapp.com/' +
        '?embed&theme=xcode&border=silver&options-color=rgba(120,120,120,0.5)' +
        '&engine=' + (if $code.hasClass('language-phug') then 'phug' else 'pug-php') +
        '&input=' + encodeURIComponent(code) +
        '&options=' + encodeURIComponent(JSON.stringify(options)) +
        '&save_as=' + saveAs +
        (if language
          '&language=' + language +
          '&hide-output'
        else
          ''
        ) +
        (if vars
          '&vars=' + encodeURIComponent(vars) + '&vars-height=' + (varsLines * 100 / (outputLines + 2 + varsLines))
        else
          '&hide-vars'
        ) +
        '" class="live-code" style="height: ' + Math.max(minHeight, lines * lineHeight + 2) + 'px;"></iframe>' +
        '<div class="live-code-resizer"></div>'
      return
    return
  $('.table-of-content').append tableOfContents
  $('body').scrollspy
    target: '#contents'
    offset: Math.round $('main').css('padding-top').replace('px','')
  sideNavLinksSelector = 'nav.sidebar .nav-link:visible'
  scrollCheck = ->
    scrollTop = $(@).scrollTop() - 10
    scrollBottom = scrollTop + $(window).height() + 20
    viewMargin = 400
    $('.chapter').each ->
      $chapter = $ @
      top = $chapter.offset().top
      method = if top <= scrollTop and top + $chapter.height() >= scrollTop
        'addClass'
      else
        'removeClass'
      $chapter.find('.edit-btn:visible')[method] 'sticky-button'
      return
    $('iframe[data-src]').each ->
      $iframe = $ @
      top = $iframe.offset().top
      if top + $iframe.height() + viewMargin > scrollTop and top - viewMargin < scrollBottom
        $iframe.prop('src', $iframe.data 'src').removeAttr 'data-src'
      return
    $links = $ sideNavLinksSelector
    index = $links.index $links.filter '.active:last'
    $('.languages a').each ->
      $link = $ @
      href = $link.prop('href').replace(/[?&]anchor=\d+/g, '')
      if index > -1 and href.indexOf('#') is -1
        href += if href.indexOf('?') is -1 then '?' else '&'
        href += 'anchor=' + index
      $link.prop 'href', href
      return
    return
  resize = {}
  $(document)
    .on 'mousedown', '.live-code-resizer', (e) ->
      editor = $(@).prev()
      while editor.length && !editor.is '.live-code'
        editor = editor.prev()
      if editor.length
        resize =
          editor: editor
          y: e.pageY
          height: editor.css('pointer-events', 'none').height()
      e.preventDefault()
      false
    .on 'scroll', scrollCheck
    .on 'click', '[data-close]', ->
      $('#' + $(@).data('close')).removeClass 'opened'
      return
    .on 'click', '[data-toggle]', ->
      $('#' + $(@).data('toggle')).toggleClass 'opened'
      return
    .on 'click', '[data-toggle="offcanvas"]', ->
      $('.navbar-toggler, .sidebar').toggleClass 'show'
      return
  anchor = $('nav.sidebar').data 'anchor'
  if anchor?
    $link = $(sideNavLinksSelector).eq anchor
    location.href = $link.prop 'href'
  do scrollCheck
  $(window)
    .on 'mousemove', (e) ->
      if resize.editor
        resize.editor.height Math.max 100, resize.height + e.pageY - resize.y
      return
    .on 'mouseup', ->
      if resize.editor
        resize.editor.css 'pointer-events', ''
        resize = {}
      return
  if /^#[a-z0-9-]+$/i.test location.hash
    hash = location.hash
    if hash is '#try'
      $('#try-link').click()
      return
    i = 0
    goToAnchor = ->
      if location.hash is hash
        $anchor = $ hash
        if $anchor.length
          $anchor[0].scrollIntoView()
        else if ++i < 100
          setTimeout goToAnchor, 100
      return
    do goToAnchor
  return

_paq = _paq || [];
_paq.push ['setDomains', ['pug-demo.herokuapp.com', 'pug-php-demo-kylekatarn.c9users.io', 'jade-filters.selfbuild.fr', 'pug-filters.selfbuild.fr', 'phug-lang.com', '*.phug-lang.com']]
_paq.push ['trackPageView']
_paq.push ['enableLinkTracking']
do ->
  u="//piwik.selfbuild.fr/"
  _paq.push ['setTrackerUrl', u+'piwik.php']
  _paq.push ['setSiteId', 18]
  d = document
  g = d.createElement 'script'
  s = d.getElementsByTagName('script')[0]
  g.type = 'text/javascript'
  g.async = true
  g.defer = true
  g.src = u + 'piwik.js'
  s.parentNode.insertBefore g, s
