var Backlog = {
  getAttributeName: function(td) {
    return td.className.replace(/\ attribute/, '');
  },
  tdClicked: function() {
    var attributes = $(this.parentNode).children();
    attributes.each(function(i) {
      if($(this).hasClass('attribute')) {
        var form_el = $('#' + Backlog.getAttributeName(this) + ':first');
        if(form_el && form_el.length > 0) {
          if(form_el[0].tagName == 'INPUT') {
            form_el[0].value = jQuery.trim($(this).text());
          } else {
            form_el[0].innerHTML = jQuery.trim($(this).text());
          }
        }
      }
    });
    var backlog = $('body')[0].id;
    $('#item-form')[0].action = '/' + backlog + '/' + this.parentNode.id.replace(/item-row-/, '');
    var attributeName = Backlog.getAttributeName(this);
    Backlog.showForm(attributeName);
    $('#' + attributeName).select();
  },
  addItem: function() {
    var backlog = $('body')[0].id;
    $('#item-form')[0].action = '/' + backlog;    
    Backlog.showForm('name');
    return false;    
  },
  showForm: function(focus) {
    $('#cover').show();
    $('#add_item_form').show();
    $('#' + focus).focus();
  },
  hideForm: function() {
    $('#cover').hide();
    $('#add_item_form').hide();
    $('#error_message').remove();    
  }
};

$(document).ready(function() {
  $('a.add_item_button').click(Backlog.addItem);
  $('#cancel_button').click(Backlog.hideForm);
  $('tr td.attribute').click(Backlog.tdClicked);
});
