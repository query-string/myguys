#= require ./friend_view
#= require ./my_view
#= require lodash

class @Wall
  constructor: (@$dom, @guestId) ->
    @friendViews           = []
    @myView                = new MyView(@$dom.find('.js-camera'))
    @$friendViewsContainer = @$dom.find('.js-friends')
    @$userStatus           = @$dom.find('#status_message')
    @bindSlack()

  refreshFriends: (friends) ->
    myFriendsIds  = _.map(@friendViews, (f) -> f.id())
    newFriendsIds = _.map(friends, (f) -> f.id)
    _.pull(myFriendsIds, @guestId)
    _.pull(newFriendsIds, @guestId)

    for commonFriendId in _.intersection(newFriendsIds, myFriendsIds)
      friendview = _.find(@friendViews, (f) -> f.id() == commonFriendId)
      friend = _.find(friends, (f) -> f.id == commonFriendId)
      friendview.redraw(friend)

    for leavingFriendId in _.difference(myFriendsIds, newFriendsIds)
      friendview = _.find(@friendViews, (f) -> f.id() == leavingFriendId)
      friendview.remove()
      _.remove(@friendViews, (f) -> f.id() == leavingFriendId)

    for incomingFriendId in _.difference(newFriendsIds, myFriendsIds)
      friend = _.find(friends, (f) -> f.id == incomingFriendId)
      friendView = new FriendView(friend)
      friendView.appendTo(@$friendViewsContainer)
      @friendViews.push(friendView)
      @bindSlack()

    for friendBrick in friends
      brick = @$dom.find(".wall__brick").filter -> $(@).data("brick-id") == friendBrick.id
      brick.attr("data-image-id", friendBrick.image_id)

  addTempFriend: (friendId) ->
    friendView = new FriendView({id: friendId})
    friendView.appendTo(@$friendViewsContainer)
    @friendViews.push(friendView)

  bindSlack: ->
    _that = @
    @$dom.find(".js-slack").on "click", (e) ->
      target   = $(e.target)
      image_id = target.parents(".wall__brick").attr("data-image-id")
      target.animate
        opacity: 0
        , 200
      $.post _that.$dom.data("slack-path"), {image_id: image_id}, (data) ->
        $("body").prepend "<div class='flash--notice'>Photo has been successfully #slacked!</div>"
        target.css
          opacity: 1.0,
          visibility: "visible"
