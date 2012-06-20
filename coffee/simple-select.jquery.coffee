###
# SimpleSelect
# Andrew Jaswa
###

that = this
$ = jQuery

$.fn.extend({
  simpleSelect: (options) ->
    $(this).each((input_field) ->
      new SimpleSelect(this, options) unless ($ this).hasClass('simple-select')
    )
})

class SimpleSelect

    # TODO: add value to the LIs if there is a value on the option
    # TODO: hide all other fancy selects when one is open.
    # TODO: wire the selections back to the real select element.

    # Takes a <select>
    # If a select it will hide and convert the element to a div with a ul.
    # If a div, it treats it like the converted div with a ul.
    #------------------------------------------------------------ instance
    constructor: (@select) ->
      @init()

    #----------------------------------------------------------- prototype

    init: () ->

      that = this
      $select = $(@select)
      @$fancyEl = $select
      @button = $select.data( 'button' )
      @maxSelected = $select.data( 'max-selected' ) || 1
      @checks = @maxSelected > 1

      if $select[0].tagName.toLowerCase() is 'select'
        $select.hide()
        @$fancyEl = @buildHtml($select)

      if @button
        @$buttonEl = $('button', @$fancyEl)
      @$selectEl = $('.select', @$fancyEl)
      @$optionsEl = $('.options', @$fancyEl)

      @bindEvents(@$fancyEl)

    # all events get bound here.
    bindEvents: ($el) ->

      that = @
      $item = $('li', @$optionsEl)
      #TOD: add other elements here.

      # TODO: make this a function
      $el.on 'click.fancyselect', (e) ->
        e.stopPropagation()

      # events for the 'select' part of the dropdown
      bindSelect = ($select, $options) ->
        $select.on 'click.fancyselect', ->
          that.toggleDropdown($el)
          if $options.is(':visible')
            $(document.body).on 'click.fancyselect', (e) ->
              that.toggleDropdown($el)
              $(document.body).off 'click.fancyselect'
          else
            $(document.body).off 'click.fancyselect'

      # click events for each option in the dropdown
      bindItems = () ->

        $item.live 'click.fancyselect', (e) ->
          # TODO: this is pretty gross


          # TODO: move this selection to an update event that gets fired on page load and on config save.
          $item = $('li', that.$optionsEl)

          text = $(@).text()

          if that.maxSelected is 1
            $item.removeClass('active')
            $(@).addClass('active')
            that.selectItem(that.$selectEl, text, $el)
            return false

          else
            # multi select
            if $(@).hasClass('active')
              # un select
              $(@).removeClass('active')
              return false
            if that.checkSelected($item)
              # checked max, under limit
              $(@).addClass('active')
              that.$fancyEl.trigger 'fancyselect.itemselect', [ text ]
            else
              # over max limit
              $el.trigger('fancyselect.maxselected')

          # TODO: why does return false work and SP doesn't?
          # e.stopPropagation()
          return false

      # listener for the button click event
      bindButtonEvent = () ->
        that.$buttonEl.on 'click.fancyselect', ->
          that.hideDropdown()
          $el.trigger 'fancyselect.buttonclick'

      bindSelect(@$selectEl, @$optionsEl)
      bindItems($item)
      if @button
        bindButtonEvent()

    # select a clicked on item in the dropdown,
    # update the place holder text
    selectItem: ($el, value, $parent) ->
      $el.find('span').text(value)
      @$fancyEl.trigger 'fancyselect.itemselect', [ value ]
      $(document.body).off 'click.fancyselect'
      @toggleDropdown($parent)

    # checks to see if which items are selected,
    # return true of false if you are trying to select more then the max
    checkSelected: ($items)->
      currentSelected = 0
      $items.each ->
        if $(this).hasClass('active')
          currentSelected++
      if currentSelected >= @maxSelected
        return false
      else
        return true

    # show/hide the dropdown
    toggleDropdown: () ->
      @$optionsEl.toggle()
      @$selectEl.toggleClass('active')

    # hide the dropdown, make public?
    hideDropdown: () ->
      @$optionsEl.hide()
      @$selectEl.removeClass('active')
      $(document.body).off 'click.fancyselect'

    # build out the html when a select element gets passed into the constructer
    # only gets called in that case.
    # returns the html of the fancy select.
    buildHtml: ($select) ->
      # TODO: need to pull this out into a js template of some sorts 
      $options = $select.find('option')
      placeholder = $select.data( 'placeholder' )
      optionalText = $select.data( 'optional' )

      optionsEls = ''
      optionsItems = ''
      checkBox = ''

      if optionalText
        optionsEls += '<div class="optional-text">'+optionalText+'</div>'
      if @checks
        checkBox = '<div class="check-box"></div>'
      $options.each ->
        optionsItems += '<li>'+ checkBox + '' +this.value+'</li>'

      optionsEls += '<ul>'+optionsItems+'</ul>'

      if @button
        optionsEls += '<div class="submit"><button>Compare</button></div>'

      selectEl = '<div class="select"><span>'+placeholder+'</span><div class="arrow"></div></div>'

      $fancyEl = $(document.createElement('div')).attr('class','fancy-select')
      $fancyEl.html(selectEl+'<div class="options">'+optionsEls+'</div></div>')
      $select.after($fancyEl)

      return $fancyEl

