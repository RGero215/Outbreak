module.exports = async function(req, res) {
    console.log("Lets delete our post")

    const postId = req.param('postId')
    console.log("Deleting post with id: " + postId)

    try {
        await Post.destroy({id: postId, user: req.session.userId})

        await FeedItem.destroy({post: postId})
        res.end()
    } catch (err) {
        res.serverError(err.toString())
    }
}