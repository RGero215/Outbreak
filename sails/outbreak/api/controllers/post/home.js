module.exports = async function(req, res) {
    const userId = req.session.userId

    // lets destroy all feed items for unfollowing id
    // await FeedItem.destroy({})
    // await Post.destroy({})

    
    
    const allPosts = []

    const feedItems = await FeedItem.find({user: userId})
        .sort('postCreatedAt DESC')
        .populate('post')
        .populate('postOwner')

    feedItems.forEach(fi => {
        // console.log(fi.postOwner)
        if(fi.post){
            fi.post.user = fi.postOwner
            fi.post.canDelete = fi.post.user.id == req.session.userId
            fi.post.hasLiked = fi.hasLiked
            // fi.post.numLikes = 5
            allPosts.push(fi.post)
        }
        
    })

    if (req.wantsJSON) {
        return res.send(allPosts)
    }

    console.log(feedItems)

    // JSON stringify and parse
    const string = JSON.stringify(allPosts)
    const objects = JSON.parse(string)
    // console.log(objects)

    res.view('pages/post/home', {
        allPosts: objects,
        layout: 'layouts/nav-layout'
    })
}