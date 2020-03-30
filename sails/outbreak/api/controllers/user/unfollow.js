module.exports = async function(req, res) {
    const currentUserId = req.session.userId
    const userIdToUnfollow = req.param('id')

    await User.removeFromCollection(currentUserId, 'following', 
        userIdToUnfollow)

    // lets destroy all feed items for unfollowing id
    await FeedItem.destroy({postOwner: userIdToUnfollow})

    await User.removeFromCollection(userIdToUnfollow, 'followers',
        currentUserId)

    res.end()
}