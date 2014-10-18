# class AutoShootControl
#   events:
#     requestStateChange

#   states:
#     COUNTDOWN
#     SHOOTING
#     PAUSED

#   methods:
#     setState: (state) ->
#     setRemainingSeconds: ->

#= require ./event_emitter

class @AutoshootControl extends EventEmitter
  constructor: (@$dom) ->
    super
    @remainingSeconds = '?'
    @setState('PAUSED')

    @$dom.on 'click', 'a', (e) =>
      e.stopPropagation()
      e.preventDefault()

      nextState = if @state == 'COUNTDOWN'
        'PAUSED'
      else if @state == 'PAUSED'
        'COUNTDOWN'

      @emit('requestStateChange', nextState) if nextState

  setState: (state) ->
    @state = state

    template = if state == 'COUNTDOWN'
      """
        <span>
          <span class='control-bar__action__normal'>Photo in #{@remainingSeconds}...</span>
          <span class='control-bar__action__hover'>Pause</span>
        </span>
      """
    else if state == 'SHOOTING'
      """
        <span>Smile! :)</span>
      """
    else if state == 'PAUSED'
      """
        <span>
          <span class='control-bar__action__normal'>Autoshoot disabled</span>
          <span class='control-bar__action__hover'>Resume</span>
        </span>
      """

    @$dom.empty().html(template)

  setRemainingSeconds: (seconds) ->
    @remainingSeconds = seconds
    @setState(@state)

