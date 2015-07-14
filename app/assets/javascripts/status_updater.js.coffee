class @StatusUpdater
  constructor: ($dom) ->
    updateUrl  = $dom.data('guest-status-url')
    statusType = $dom.data("type")

    $dom.bind 'keypress', (e) ->
      if e.keyCode == 13
        $('.js-my-status-' + statusType).text($dom.val())
        $.ajax
          url: updateUrl,
          type: 'PUT',
          data: {status_value: $dom.val(), status_type: statusType}
          success: ->
            $dom.blur()
            $dom.val('') if statusType == "message"
