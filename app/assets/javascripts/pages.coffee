# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#from').mask('00/00/0000 00:00');
  $('#to').mask('00/00/0000 00:00');


$(document).on "click", ".expand-action", (event) ->
  target = $(event.target).parent()

  event.preventDefault()
  before_log = target.data('before-log')
  after_log = target.data('after-log')

  $.ajax
    url: "/"
    dataType: "script"
    type: "GET"
    data:
      expand: true
      before_log: before_log
      after_log: after_log
      current: target.closest('tr').prop('id')
