# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(window).load ->
  console.log("Transactions is loading")
  unless typeof gon is 'undefined'
    braintree.setup(gon.client_token, 'dropin', { container: 'dropin' });
