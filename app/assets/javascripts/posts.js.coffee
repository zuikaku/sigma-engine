# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

form_moved        = false
highlighted_post  = off
showing_thread    = false
unknown_error     = 'Неизвестная ошибка. Перезагрузите страницу.'

$(document).ready ->
  $('#thread_form').submit(submit_thread)
  $('#reply_form').submit(submit_reply)
  $('.reply_link').click(move_reply_form)
  $('#reply_form textarea').bind('keydown', 'ctrl+return', -> $(this).submit())
  $('.ajax_detector').attr('checked', true)
  return false

submit_thread = ->
  form   = $(this)
  button = form.find('.submit_button')
  errors = form.find('.errors')
  form.ajaxSubmit
    beforeSubmit: blur_form(form, errors)
    success: (response) ->
      window.location = response
    error: (response) ->
      unblur_form(form)
      if response.status == 500
        errors.html(unknown_error)
      else
        errors.html(response.responseText)
  return false

submit_reply = ->
  form    = $('#reply_form')
  errors  = form.find('.errors')
  thread  = form.parent().parent()
  showing_thread = thread.hasClass('the_one_and_only')
  form.ajaxSubmit
    beforeSubmit: blur_form(form, errors)
    success: (response) ->
      unblur_form(form)
      clear_form(form)
      post = $(response)
      thread.append(post)
      post.css('opacity', 0)
      post.animate({opacity: 1}, 800)
      $.scrollTo(post, settings = {offset: {top: 50}})
      if not showing_thread
        $('#reply_form_container').css('display', 'none')
      else
        post.after(form.parent())
      $('.reply_link').unbind().click(move_reply_form)
    error: (response) ->
      unblur_form(form)
      if response.status == 500
        errors.html(unknown_error)
      else
        errors.html(response.responseText)
  return false

move_reply_form = ->
  container = $('#reply_form_container')
  post      = $(this).parent().parent()
  textarea  = container.find('textarea')
  showing_thread = container.parent().hasClass('the_one_and_only')
  container.css('display', 'table') if not showing_thread
  post.after(container)
  textarea.focus()
  textarea.val(textarea.val() + ">>#{post.attr 'id'}\n")
  if showing_thread
    form_moved = true
  else
    if post.hasClass('reply')
      thread_id = post.parent().find('.thread').attr('id')
    else
      thread_id = post.attr('id')
    action = "/threads/#{thread_id}/reply"
    container.find('form').attr('action', action)
  $.scrollTo(post, settings = offset: {top: -200})
  return false
  
blur_form = (form, errors) ->
  form.find('textarea').blur()
  form.find('input').blur()
  form.find('.submit_button').attr('disabled', true)
  form.find('.submit_button').attr('value', 'отправляем...')
  form.find('.loading').css('z-index', '3')
  errors.html('')
  form.animate({opacity: 0.4}, 400).delay(400)
  return false

unblur_form = (form) ->
  form.find('.submit_button').removeAttr('disabled')
  form.find('.submit_button').attr('value', 'отправить')
  form.find('.loading').css('z-index', '1')
  form.animate({opacity: 1}, 400).delay(400)
  return false

show_errors = (div, errors) ->
  html = ""
  for error in errors
    html += (error + '<br/>')
  div.html(html)
  return false

clear_form = (form) =>
  form.find('textarea').val('')
  form.find('.file_field').val('')