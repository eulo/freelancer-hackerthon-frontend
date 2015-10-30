$ = require 'jquery'
_ = require 'underscore'
Handlebars = require 'hbsfy/runtime'

require 'seiyria-bootstrap-slider'
require 'typeahead.js'
require 'raty'

ResultItem = require '../../tmpl/result-item.hbs'
TeamItem = require '../../tmpl/team-member.hbs'
ChatDialog = require '../../tmpl/chat-dialog.hbs'

#Globals

$results = $('.results-output')

USERS = []
skillsList = []
RATY_OPTIONS =
  starHalf    : '/assets/img/star-half.png'
  starOff     : '/assets/img/star-off.png'
  starOn      : '/assets/img/star-on.png'
  cancelOff   : '/assets/img/cancel-off.png'
  cancelOn    : '/assets/img/cancel-on.png'

#Inits

$('.range-slider').slider({})

# Func
prepareItem = (el) ->
  el.jobs = el.jobs.slice(0, 5)
  el.star_rating = (Math.round(el.reputation.entire_history.overall * 10) / 10).toFixed(1)
  $el = $ ResultItem el
  $el.find('.user-rating-progress')
    .width(Math.round(20 * el.reputation.entire_history.overall) + '%')
  return $el

queueAppend = (results) ->
  t = 0
  queue = (res) =>
    setTimeout () =>
      if !$('.results-output .loader').length
        $results.append res

    , t
  for res in results
    queue res
    t += 250

# Binds
$('.results-output').on 'click', '.invite-button', (event) ->
  user_id = $(@).data('user_id')
  user_obj = _.find USERS, (el) ->
    return el.id == user_id
  if !$('.team-output .team-member').length
    $('.team-output').empty()
  user_obj.jobs = user_obj.jobs.slice(0,3)
  $('.team-output').append $ TeamItem user_obj


$('.results-output').on 'click', '.chat-button', (event) ->
  user_id = $(@).data('user_id')
  user_obj = _.find USERS, (el) ->
    return el.id == user_id
  $('.chat-dialog').remove()
  $('body').append $ ChatDialog user_obj

$('.team-output').on 'click', '.remove-member', (event) ->
  $(@).parent().remove()

$('body').on 'submit', '.chat-dialog form', (event) ->
  event.preventDefault()
  if $('.chat-dialog').find('input').val() == ''
    return false
  $('.chat-messages').append "<p>#{$('.chat-dialog').find('input').val()}</p>"
  $('.chat-dialog').find('input').val('')
  return false

$('body').on 'click', '.chat-dialog .panel-heading', ()->
  $(this).parent().remove()


$.get '//api.freelancer.dev/users', (res)->

  $results.empty()

  if res && res.status == 'success'
    USERS = USERS.concat res.result.users
    markup = []
    _.each res.result.users, (el, i, arr)->
      markup.push prepareItem el
    queueAppend markup
  else
    $results.append '<h3>Something went wrong&hellip;</h3>'
 

$('.results-filter form').submit (event) ->
  event.preventDefault()

  jobs = _.reduce skillsList, (a, b) ->
    return "#{a},#{b.slug}"
  , ''
  jobs = jobs.slice(1)
  data =
    'jobs[]' : jobs

  $.get '//api.freelancer.dev/users', data, (res)->

    $results.empty()

    if res && res.status == 'success'
      USERS = USERS.concat res.result.users
      markup = []
      _.each res.result.users, (el, i, arr)->
        markup.push prepareItem el
      queueAppend markup
    else
      $results.append '<h3>No results found</h3>'
 
  return false


# Get skills
$.get '//api.freelancer.dev/skills', (res) ->
  if !res || res.status != 'success'
    return

  skills = []
  for obj in res.result
    item =
      name : obj.name
      slug : obj.id
      type : obj.category.name
    skills.push item

  skills = new Bloodhound
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    limit: 5
    local: skills
  skills.initialize()

  $('.typeahead').typeahead
    hint: true
    highlight: true
    minLength: 1
  ,
    name: 'skills'
    displayKey: 'name'
    source: skills.ttAdapter()
    templates:
      header: "<h3 class='tt-title'>Skills</h3>"

  current = ''
  $('.typeahead').on "typeahead:selected", (event, datum)->
    current = datum
  $('.typeahead').on "typeahead:autocompleted", (event, datum)->
    current = datum

  $skillsOutput = $('.skills-output')

  $('.typeahead').keypress (event) ->
    if event.keycode == 13 || event.which == 13
      if current != '' && !_.contains(skillsList, current)
        skillsList.push current
        $skillsOutput.append $("<button type='button' class='btn btn-default btn-sm'><span class='glyphicon glyphicon-remove' aria-hidden='true'></span> #{current.name}</button>")
        $('.typeahead').typeahead('val', '')
        $('.typeahead').typeahead('close')


  $('.typeahead-add').click ->
    if current != '' && !_.contains(skillsList, current)
      skillsList.push current
      $skillsOutput.append $("<button type='button' class='btn btn-default btn-sm' data-name='#{current.name}'><span class='glyphicon glyphicon-remove' aria-hidden='true'></span> #{current.name}</button>")
      $('.typeahead').typeahead('val', '')
      $('.typeahead').typeahead('close')

  $skillsOutput.on 'click', 'button', (event) ->
    $self = $(@)
    skillsList = _.filter skillsList, (el)->
      return el.name != $self.data 'name'
    $self.remove()

 
