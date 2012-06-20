
/*
# SimpleSelect
# Andrew Jaswa
*/

(function() {
  var $, SimpleSelect, that;

  that = this;

  $ = jQuery;

  $.fn.extend({
    simpleSelect: function(options) {
      return $(this).each(function(input_field) {
        if (!($(this)).hasClass('simple-select')) {
          return new SimpleSelect(this, options);
        }
      });
    }
  });

  SimpleSelect = (function() {

    function SimpleSelect(select) {
      this.select = select;
      this.init();
    }

    SimpleSelect.prototype.init = function() {
      var $select;
      that = this;
      $select = $(this.select);
      this.$fancyEl = $select;
      this.button = $select.data('button');
      this.maxSelected = $select.data('max-selected') || 1;
      this.checks = this.maxSelected > 1;
      if ($select[0].tagName.toLowerCase() === 'select') {
        $select.hide();
        this.$fancyEl = this.buildHtml($select);
      }
      if (this.button) this.$buttonEl = $('button', this.$fancyEl);
      this.$selectEl = $('.select', this.$fancyEl);
      this.$optionsEl = $('.options', this.$fancyEl);
      return this.bindEvents(this.$fancyEl);
    };

    SimpleSelect.prototype.bindEvents = function($el) {
      var $item, bindButtonEvent, bindItems, bindSelect;
      that = this;
      $item = $('li', this.$optionsEl);
      $el.on('click.fancyselect', function(e) {
        return e.stopPropagation();
      });
      bindSelect = function($select, $options) {
        return $select.on('click.fancyselect', function() {
          that.toggleDropdown($el);
          if ($options.is(':visible')) {
            return $(document.body).on('click.fancyselect', function(e) {
              that.toggleDropdown($el);
              return $(document.body).off('click.fancyselect');
            });
          } else {
            return $(document.body).off('click.fancyselect');
          }
        });
      };
      bindItems = function() {
        return $item.live('click.fancyselect', function(e) {
          var text;
          $item = $('li', that.$optionsEl);
          text = $(this).text();
          if (that.maxSelected === 1) {
            $item.removeClass('active');
            $(this).addClass('active');
            that.selectItem(that.$selectEl, text, $el);
            return false;
          } else {
            if ($(this).hasClass('active')) {
              $(this).removeClass('active');
              return false;
            }
            if (that.checkSelected($item)) {
              $(this).addClass('active');
              that.$fancyEl.trigger('fancyselect.itemselect', [text]);
            } else {
              $el.trigger('fancyselect.maxselected');
            }
          }
          return false;
        });
      };
      bindButtonEvent = function() {
        return that.$buttonEl.on('click.fancyselect', function() {
          that.hideDropdown();
          return $el.trigger('fancyselect.buttonclick');
        });
      };
      bindSelect(this.$selectEl, this.$optionsEl);
      bindItems($item);
      if (this.button) return bindButtonEvent();
    };

    SimpleSelect.prototype.selectItem = function($el, value, $parent) {
      $el.find('span').text(value);
      this.$fancyEl.trigger('fancyselect.itemselect', [value]);
      $(document.body).off('click.fancyselect');
      return this.toggleDropdown($parent);
    };

    SimpleSelect.prototype.checkSelected = function($items) {
      var currentSelected;
      currentSelected = 0;
      $items.each(function() {
        if ($(this).hasClass('active')) return currentSelected++;
      });
      if (currentSelected >= this.maxSelected) {
        return false;
      } else {
        return true;
      }
    };

    SimpleSelect.prototype.toggleDropdown = function() {
      this.$optionsEl.toggle();
      return this.$selectEl.toggleClass('active');
    };

    SimpleSelect.prototype.hideDropdown = function() {
      this.$optionsEl.hide();
      this.$selectEl.removeClass('active');
      return $(document.body).off('click.fancyselect');
    };

    SimpleSelect.prototype.buildHtml = function($select) {
      var $fancyEl, $options, checkBox, optionalText, optionsEls, optionsItems, placeholder, selectEl;
      $options = $select.find('option');
      placeholder = $select.data('placeholder');
      optionalText = $select.data('optional');
      optionsEls = '';
      optionsItems = '';
      checkBox = '';
      if (optionalText) {
        optionsEls += '<div class="optional-text">' + optionalText + '</div>';
      }
      if (this.checks) checkBox = '<div class="check-box"></div>';
      $options.each(function() {
        return optionsItems += '<li>' + checkBox + '' + this.value + '</li>';
      });
      optionsEls += '<ul>' + optionsItems + '</ul>';
      if (this.button) {
        optionsEls += '<div class="submit"><button>Compare</button></div>';
      }
      selectEl = '<div class="select"><span>' + placeholder + '</span><div class="arrow"></div></div>';
      $fancyEl = $(document.createElement('div')).attr('class', 'fancy-select');
      $fancyEl.html(selectEl + '<div class="options">' + optionsEls + '</div></div>');
      $select.after($fancyEl);
      return $fancyEl;
    };

    return SimpleSelect;

  })();

}).call(this);
